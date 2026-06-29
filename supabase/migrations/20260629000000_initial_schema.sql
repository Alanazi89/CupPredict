-- CupPredict production Supabase schema
-- PostgreSQL 15+, Supabase Auth, Row Level Security enabled by default.

begin;

create extension if not exists pgcrypto;
create extension if not exists citext;

create type public.app_role as enum ('user', 'analyst', 'admin', 'service');
create type public.tournament_status as enum ('draft', 'scheduled', 'active', 'completed', 'archived');
create type public.round_stage as enum ('group', 'round_of_32', 'round_of_16', 'quarter_final', 'semi_final', 'third_place', 'final');
create type public.match_status as enum ('scheduled', 'live', 'completed', 'postponed', 'cancelled');
create type public.prediction_status as enum ('draft', 'submitted', 'locked', 'scored', 'void');
create type public.prediction_outcome as enum ('home_win', 'draw', 'away_win');
create type public.notification_type as enum ('system', 'match', 'prediction', 'achievement', 'league');
create type public.audit_action as enum ('insert', 'update', 'delete', 'login', 'score', 'admin');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username citext not null unique,
  display_name text not null,
  avatar_url text,
  role public.app_role not null default 'user',
  country_code char(2),
  favorite_team_id uuid,
  marketing_opt_in boolean not null default false,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_format check (username ~ '^[a-zA-Z0-9_]{3,30}$')
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  fifa_code char(3) not null unique,
  name text not null unique,
  confederation text not null,
  flag_emoji text,
  country_code char(2),
  elo_rating integer not null default 1500 check (elo_rating between 500 and 3000),
  primary_color text not null default '#38bdf8',
  secondary_color text not null default '#0f172a',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add constraint profiles_favorite_team_id_fkey foreign key (favorite_team_id) references public.teams(id) on delete set null;

create table public.tournaments (
  id uuid primary key default gen_random_uuid(),
  slug citext not null unique,
  name text not null,
  host_country text not null,
  status public.tournament_status not null default 'draft',
  starts_on date not null,
  ends_on date not null,
  prediction_lock_at timestamptz,
  scoring_rules jsonb not null default '{"correct_outcome": 3, "correct_score": 5, "correct_winner": 2}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tournaments_dates_valid check (ends_on >= starts_on)
);

create table public.tournament_teams (
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete restrict,
  group_code text,
  seed integer check (seed > 0),
  qualified_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (tournament_id, team_id),
  unique (tournament_id, seed)
);

create table public.rounds (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  stage public.round_stage not null,
  name text not null,
  sort_order integer not null check (sort_order > 0),
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tournament_id, stage),
  unique (tournament_id, sort_order),
  constraint rounds_dates_valid check (ends_at is null or starts_at is null or ends_at >= starts_at)
);

create table public.matches (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  round_id uuid not null references public.rounds(id) on delete restrict,
  home_team_id uuid not null references public.teams(id) on delete restrict,
  away_team_id uuid not null references public.teams(id) on delete restrict,
  match_number integer not null,
  venue text,
  city text,
  kickoff_at timestamptz not null,
  status public.match_status not null default 'scheduled',
  home_score integer check (home_score >= 0),
  away_score integer check (away_score >= 0),
  home_penalties integer check (home_penalties >= 0),
  away_penalties integer check (away_penalties >= 0),
  winner_team_id uuid references public.teams(id) on delete restrict,
  locked_at timestamptz generated always as (kickoff_at - interval '5 minutes') stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tournament_id, match_number),
  constraint matches_distinct_teams check (home_team_id <> away_team_id),
  constraint matches_scores_required_when_completed check (status <> 'completed' or (home_score is not null and away_score is not null))
);

create table public.predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  match_id uuid not null references public.matches(id) on delete cascade,
  league_id uuid,
  predicted_outcome public.prediction_outcome not null,
  predicted_home_score integer not null check (predicted_home_score >= 0),
  predicted_away_score integer not null check (predicted_away_score >= 0),
  confidence smallint not null default 50 check (confidence between 1 and 100),
  status public.prediction_status not null default 'submitted',
  submitted_at timestamptz not null default now(),
  locked_at timestamptz,
  scored_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, match_id, league_id)
);

create table public.scoring_events (
  id uuid primary key default gen_random_uuid(),
  prediction_id uuid not null references public.predictions(id) on delete cascade,
  points integer not null default 0,
  exact_score_points integer not null default 0,
  outcome_points integer not null default 0,
  confidence_bonus integer not null default 0,
  streak_bonus integer not null default 0,
  reason text not null,
  scored_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (prediction_id)
);

create table public.leagues (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  slug citext not null unique,
  name text not null,
  description text,
  invite_code citext not null unique default encode(gen_random_bytes(6), 'hex'),
  is_public boolean not null default false,
  max_members integer check (max_members is null or max_members > 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.predictions
  add constraint predictions_league_id_fkey foreign key (league_id) references public.leagues(id) on delete cascade;

create table public.league_members (
  league_id uuid not null references public.leagues(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.app_role not null default 'user',
  joined_at timestamptz not null default now(),
  primary key (league_id, user_id)
);

create table public.leaderboard_snapshots (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  league_id uuid references public.leagues(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  points integer not null default 0,
  exact_scores integer not null default 0,
  correct_outcomes integer not null default 0,
  predictions_count integer not null default 0,
  rank integer not null check (rank > 0),
  snapshot_at timestamptz not null default now(),
  unique (tournament_id, league_id, user_id, snapshot_at)
);

create table public.achievements (
  id uuid primary key default gen_random_uuid(),
  slug citext not null unique,
  name text not null,
  description text not null,
  icon text not null default 'trophy',
  points integer not null default 0,
  criteria jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.user_achievements (
  user_id uuid not null references public.profiles(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  tournament_id uuid references public.tournaments(id) on delete cascade,
  earned_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  primary key (user_id, achievement_id, tournament_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type public.notification_type not null,
  title text not null,
  body text not null,
  action_url text,
  read_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  action public.audit_action not null,
  table_name text not null,
  record_id text not null,
  old_record jsonb,
  new_record jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

-- Indexes
create index profiles_role_idx on public.profiles(role);
create index teams_confederation_idx on public.teams(confederation);
create index tournaments_status_dates_idx on public.tournaments(status, starts_on, ends_on);
create index tournament_teams_team_idx on public.tournament_teams(team_id);
create index rounds_tournament_sort_idx on public.rounds(tournament_id, sort_order);
create index matches_tournament_kickoff_idx on public.matches(tournament_id, kickoff_at);
create index matches_round_idx on public.matches(round_id);
create index matches_status_idx on public.matches(status);
create index predictions_user_idx on public.predictions(user_id, submitted_at desc);
create index predictions_match_idx on public.predictions(match_id);
create index predictions_league_idx on public.predictions(league_id) where league_id is not null;
create unique index predictions_one_global_per_match_idx on public.predictions(user_id, match_id) where league_id is null;
create unique index predictions_one_league_per_match_idx on public.predictions(user_id, match_id, league_id) where league_id is not null;
create index scoring_events_prediction_idx on public.scoring_events(prediction_id);
create index league_members_user_idx on public.league_members(user_id);
create index leaderboard_lookup_idx on public.leaderboard_snapshots(tournament_id, league_id, rank, points desc);
create index notifications_unread_idx on public.notifications(user_id, created_at desc) where read_at is null;
create index audit_logs_actor_created_idx on public.audit_logs(actor_id, created_at desc);
create index audit_logs_table_record_idx on public.audit_logs(table_name, record_id);

-- Utility functions
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.current_user_role()
returns public.app_role language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'user'::public.app_role);
$$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select public.current_user_role() in ('admin', 'service');
$$;

create or replace function public.is_league_member(target_league_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.league_members lm
    where lm.league_id = target_league_id and lm.user_id = auth.uid()
  );
$$;

create or replace function public.prevent_late_prediction()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  match_lock timestamptz;
begin
  select locked_at into match_lock from public.matches where id = new.match_id;
  if match_lock is null then
    raise exception 'match % does not exist', new.match_id;
  end if;
  if now() >= match_lock and not public.is_admin() then
    raise exception 'predictions are locked for this match';
  end if;
  new.locked_at = match_lock;
  return new;
end;
$$;

create or replace function public.match_outcome(home_score integer, away_score integer)
returns public.prediction_outcome language sql immutable as $$
  select case
    when home_score > away_score then 'home_win'::public.prediction_outcome
    when home_score < away_score then 'away_win'::public.prediction_outcome
    else 'draw'::public.prediction_outcome
  end;
$$;

create or replace function public.calculate_prediction_points(target_prediction_id uuid)
returns integer language plpgsql security definer set search_path = public as $$
declare
  p record;
  m record;
  rules jsonb;
  outcome_points integer := 0;
  exact_points integer := 0;
  confidence_points integer := 0;
  total integer := 0;
begin
  select * into p from public.predictions where id = target_prediction_id;
  if not found then raise exception 'prediction not found'; end if;

  select m.*, t.scoring_rules into m
  from public.matches m
  join public.tournaments t on t.id = m.tournament_id
  where m.id = p.match_id;

  if m.status <> 'completed' then
    raise exception 'match is not completed';
  end if;

  rules := m.scoring_rules;
  if p.predicted_outcome = public.match_outcome(m.home_score, m.away_score) then
    outcome_points := coalesce((rules->>'correct_outcome')::integer, 3);
  end if;
  if p.predicted_home_score = m.home_score and p.predicted_away_score = m.away_score then
    exact_points := coalesce((rules->>'correct_score')::integer, 5);
  end if;
  if outcome_points > 0 and p.confidence >= 80 then
    confidence_points := 1;
  end if;

  total := outcome_points + exact_points + confidence_points;

  insert into public.scoring_events (prediction_id, points, exact_score_points, outcome_points, confidence_bonus, reason)
  values (p.id, total, exact_points, outcome_points, confidence_points, 'automatic match scoring')
  on conflict (prediction_id) do update set
    points = excluded.points,
    exact_score_points = excluded.exact_score_points,
    outcome_points = excluded.outcome_points,
    confidence_bonus = excluded.confidence_bonus,
    reason = excluded.reason,
    created_at = now();

  update public.predictions set status = 'scored', scored_at = now() where id = p.id;
  return total;
end;
$$;

create or replace function public.score_completed_match(target_match_id uuid)
returns integer language plpgsql security definer set search_path = public as $$
declare
  scored_count integer := 0;
  prediction record;
begin
  if not public.is_admin() then
    raise exception 'admin privileges required';
  end if;
  for prediction in select id from public.predictions where match_id = target_match_id and status in ('submitted', 'locked') loop
    perform public.calculate_prediction_points(prediction.id);
    scored_count := scored_count + 1;
  end loop;
  return scored_count;
end;
$$;

create or replace function public.refresh_leaderboard_snapshot(target_tournament_id uuid, target_league_id uuid default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.leaderboard_snapshots (tournament_id, league_id, user_id, points, exact_scores, correct_outcomes, predictions_count, rank)
  select
    target_tournament_id,
    target_league_id,
    p.user_id,
    coalesce(sum(se.points), 0)::integer as points,
    count(*) filter (where se.exact_score_points > 0)::integer as exact_scores,
    count(*) filter (where se.outcome_points > 0)::integer as correct_outcomes,
    count(*)::integer as predictions_count,
    dense_rank() over (order by coalesce(sum(se.points), 0) desc, count(*) filter (where se.exact_score_points > 0) desc)::integer as rank
  from public.predictions p
  join public.matches m on m.id = p.match_id
  left join public.scoring_events se on se.prediction_id = p.id
  where m.tournament_id = target_tournament_id
    and (target_league_id is null or p.league_id = target_league_id)
  group by p.user_id;
end;
$$;

create or replace function public.join_league_by_invite(target_invite_code citext)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  target_league public.leagues;
begin
  select * into target_league from public.leagues where invite_code = target_invite_code;
  if not found then raise exception 'invalid invite code'; end if;
  insert into public.league_members (league_id, user_id) values (target_league.id, auth.uid()) on conflict do nothing;
  return target_league.id;
end;
$$;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, username, display_name, avatar_url)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'username', ''), split_part(new.email, '@', 1), 'user_' || substr(new.id::text, 1, 8)),
    coalesce(nullif(new.raw_user_meta_data->>'display_name', ''), split_part(new.email, '@', 1), 'CupPredict User'),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace function public.audit_row_change()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  changed_record_id text;
begin
  changed_record_id := case when tg_op = 'DELETE' then old.id::text else new.id::text end;
  insert into public.audit_logs(actor_id, action, table_name, record_id, old_record, new_record)
  values (
    auth.uid(),
    lower(tg_op)::public.audit_action,
    tg_table_name,
    changed_record_id,
    case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end,
    case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end
  );
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create or replace procedure public.admin_score_match(target_match_id uuid)
language plpgsql security definer set search_path = public as $$
begin
  perform public.score_completed_match(target_match_id);
end;
$$;

create or replace procedure public.admin_refresh_leaderboards(target_tournament_id uuid)
language plpgsql security definer set search_path = public as $$
declare
  league record;
begin
  perform public.refresh_leaderboard_snapshot(target_tournament_id, null);
  for league in select id from public.leagues where tournament_id = target_tournament_id loop
    perform public.refresh_leaderboard_snapshot(target_tournament_id, league.id);
  end loop;
end;
$$;

-- Triggers
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
create trigger profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger teams_updated_at before update on public.teams for each row execute function public.set_updated_at();
create trigger tournaments_updated_at before update on public.tournaments for each row execute function public.set_updated_at();
create trigger rounds_updated_at before update on public.rounds for each row execute function public.set_updated_at();
create trigger matches_updated_at before update on public.matches for each row execute function public.set_updated_at();
create trigger predictions_updated_at before update on public.predictions for each row execute function public.set_updated_at();
create trigger leagues_updated_at before update on public.leagues for each row execute function public.set_updated_at();
create trigger predictions_lock_guard before insert or update on public.predictions for each row execute function public.prevent_late_prediction();

create trigger audit_profiles after insert or update or delete on public.profiles for each row execute function public.audit_row_change();
create trigger audit_predictions after insert or update or delete on public.predictions for each row execute function public.audit_row_change();
create trigger audit_leagues after insert or update or delete on public.leagues for each row execute function public.audit_row_change();
create trigger audit_matches after insert or update or delete on public.matches for each row execute function public.audit_row_change();

-- Views
create or replace view public.match_cards with (security_invoker = true) as
select
  m.id,
  m.tournament_id,
  t.name as tournament_name,
  r.name as round_name,
  r.stage,
  m.match_number,
  m.kickoff_at,
  m.status,
  home.name as home_team,
  home.fifa_code as home_code,
  away.name as away_team,
  away.fifa_code as away_code,
  m.home_score,
  m.away_score,
  m.winner_team_id
from public.matches m
join public.tournaments t on t.id = m.tournament_id
join public.rounds r on r.id = m.round_id
join public.teams home on home.id = m.home_team_id
join public.teams away on away.id = m.away_team_id;

create or replace view public.user_prediction_scores with (security_invoker = true) as
select
  p.user_id,
  m.tournament_id,
  p.league_id,
  count(p.id)::integer as predictions_count,
  coalesce(sum(se.points), 0)::integer as total_points,
  count(*) filter (where se.exact_score_points > 0)::integer as exact_scores,
  count(*) filter (where se.outcome_points > 0)::integer as correct_outcomes
from public.predictions p
join public.matches m on m.id = p.match_id
left join public.scoring_events se on se.prediction_id = p.id
group by p.user_id, m.tournament_id, p.league_id;

create or replace view public.current_leaderboards with (security_invoker = true) as
select distinct on (ls.tournament_id, ls.league_id, ls.user_id)
  ls.*,
  pr.username,
  pr.display_name,
  pr.avatar_url
from public.leaderboard_snapshots ls
join public.profiles pr on pr.id = ls.user_id
order by ls.tournament_id, ls.league_id, ls.user_id, ls.snapshot_at desc;

-- RLS
alter table public.profiles enable row level security;
alter table public.teams enable row level security;
alter table public.tournaments enable row level security;
alter table public.tournament_teams enable row level security;
alter table public.rounds enable row level security;
alter table public.matches enable row level security;
alter table public.predictions enable row level security;
alter table public.scoring_events enable row level security;
alter table public.leagues enable row level security;
alter table public.league_members enable row level security;
alter table public.leaderboard_snapshots enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_logs enable row level security;

create policy profiles_select on public.profiles for select using (true);
create policy profiles_insert_self on public.profiles for insert with check (id = auth.uid());
create policy profiles_update_self_or_admin on public.profiles for update using (id = auth.uid() or public.is_admin()) with check (id = auth.uid() or public.is_admin());

create policy public_read_teams on public.teams for select using (true);
create policy admin_write_teams on public.teams for all using (public.is_admin()) with check (public.is_admin());
create policy public_read_tournaments on public.tournaments for select using (true);
create policy admin_write_tournaments on public.tournaments for all using (public.is_admin()) with check (public.is_admin());
create policy public_read_tournament_teams on public.tournament_teams for select using (true);
create policy admin_write_tournament_teams on public.tournament_teams for all using (public.is_admin()) with check (public.is_admin());
create policy public_read_rounds on public.rounds for select using (true);
create policy admin_write_rounds on public.rounds for all using (public.is_admin()) with check (public.is_admin());
create policy public_read_matches on public.matches for select using (true);
create policy admin_write_matches on public.matches for all using (public.is_admin()) with check (public.is_admin());

create policy predictions_select_own_or_league on public.predictions for select using (
  user_id = auth.uid() or public.is_admin() or (league_id is not null and public.is_league_member(league_id))
);
create policy predictions_insert_own on public.predictions for insert with check (
  user_id = auth.uid() and (league_id is null or public.is_league_member(league_id))
);
create policy predictions_update_own_before_lock on public.predictions for update using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy predictions_delete_admin on public.predictions for delete using (public.is_admin());

create policy scoring_select_visible on public.scoring_events for select using (
  exists (select 1 from public.predictions p where p.id = prediction_id and (p.user_id = auth.uid() or public.is_admin() or (p.league_id is not null and public.is_league_member(p.league_id))))
);
create policy scoring_admin_write on public.scoring_events for all using (public.is_admin()) with check (public.is_admin());

create policy leagues_select_public_or_member on public.leagues for select using (is_public or owner_id = auth.uid() or public.is_league_member(id) or public.is_admin());
create policy leagues_insert_owner on public.leagues for insert with check (owner_id = auth.uid());
create policy leagues_update_owner_or_admin on public.leagues for update using (owner_id = auth.uid() or public.is_admin()) with check (owner_id = auth.uid() or public.is_admin());
create policy league_members_select_member on public.league_members for select using (user_id = auth.uid() or public.is_league_member(league_id) or public.is_admin());
create policy league_members_insert_self on public.league_members for insert with check (user_id = auth.uid() or public.is_admin());
create policy league_members_delete_self_owner_admin on public.league_members for delete using (user_id = auth.uid() or public.is_admin() or exists (select 1 from public.leagues l where l.id = league_id and l.owner_id = auth.uid()));

create policy leaderboards_select_public_or_member on public.leaderboard_snapshots for select using (league_id is null or public.is_league_member(league_id) or public.is_admin());
create policy leaderboards_admin_write on public.leaderboard_snapshots for all using (public.is_admin()) with check (public.is_admin());

create policy achievements_select_all on public.achievements for select using (true);
create policy achievements_admin_write on public.achievements for all using (public.is_admin()) with check (public.is_admin());
create policy user_achievements_select_visible on public.user_achievements for select using (user_id = auth.uid() or public.is_admin());
create policy user_achievements_admin_write on public.user_achievements for all using (public.is_admin()) with check (public.is_admin());

create policy notifications_select_own on public.notifications for select using (user_id = auth.uid() or public.is_admin());
create policy notifications_update_own on public.notifications for update using (user_id = auth.uid() or public.is_admin()) with check (user_id = auth.uid() or public.is_admin());
create policy notifications_admin_insert on public.notifications for insert with check (public.is_admin());
create policy audit_logs_admin_select on public.audit_logs for select using (public.is_admin());
create policy audit_logs_no_client_write on public.audit_logs for insert with check (false);

commit;
