-- CupPredict seed data for local Supabase development.
-- Run after migrations. Auth-backed user/profile rows are intentionally not seeded.

begin;

insert into public.teams (fifa_code, name, confederation, flag_emoji, country_code, elo_rating, primary_color, secondary_color) values
  ('BRA', 'Brazil', 'CONMEBOL', '🇧🇷', 'BR', 2140, '#facc15', '#16a34a'),
  ('FRA', 'France', 'UEFA', '🇫🇷', 'FR', 2098, '#2563eb', '#ef4444'),
  ('ARG', 'Argentina', 'CONMEBOL', '🇦🇷', 'AR', 2112, '#38bdf8', '#ffffff'),
  ('ENG', 'England', 'UEFA', '🏴', 'GB', 2034, '#f8fafc', '#ef4444'),
  ('ESP', 'Spain', 'UEFA', '🇪🇸', 'ES', 1988, '#ef4444', '#facc15'),
  ('GER', 'Germany', 'UEFA', '🇩🇪', 'DE', 1964, '#111827', '#facc15'),
  ('POR', 'Portugal', 'UEFA', '🇵🇹', 'PT', 1956, '#16a34a', '#ef4444'),
  ('USA', 'United States', 'CONCACAF', '🇺🇸', 'US', 1840, '#1d4ed8', '#ef4444')
on conflict (fifa_code) do update set
  name = excluded.name,
  confederation = excluded.confederation,
  flag_emoji = excluded.flag_emoji,
  country_code = excluded.country_code,
  elo_rating = excluded.elo_rating,
  primary_color = excluded.primary_color,
  secondary_color = excluded.secondary_color;

insert into public.tournaments (slug, name, host_country, status, starts_on, ends_on, prediction_lock_at, scoring_rules) values
  ('world-cup-2026', 'World Cup 2026', 'Canada, Mexico, United States', 'scheduled', '2026-06-11', '2026-07-19', '2026-06-11 18:00:00+00', '{"correct_outcome": 3, "correct_score": 5, "correct_winner": 2}'::jsonb)
on conflict (slug) do update set
  name = excluded.name,
  host_country = excluded.host_country,
  status = excluded.status,
  starts_on = excluded.starts_on,
  ends_on = excluded.ends_on,
  prediction_lock_at = excluded.prediction_lock_at,
  scoring_rules = excluded.scoring_rules;

with tournament as (select id from public.tournaments where slug = 'world-cup-2026')
insert into public.tournament_teams (tournament_id, team_id, group_code, seed)
select tournament.id, teams.id, seeded.group_code, seeded.seed
from tournament
join (values
  ('BRA'::char(3), 'A', 1), ('FRA'::char(3), 'A', 2), ('ARG'::char(3), 'B', 3), ('ENG'::char(3), 'B', 4),
  ('ESP'::char(3), 'C', 5), ('GER'::char(3), 'C', 6), ('POR'::char(3), 'D', 7), ('USA'::char(3), 'D', 8)
) as seeded(fifa_code, group_code, seed) on true
join public.teams on teams.fifa_code = seeded.fifa_code
on conflict (tournament_id, team_id) do update set group_code = excluded.group_code, seed = excluded.seed;

with tournament as (select id from public.tournaments where slug = 'world-cup-2026')
insert into public.rounds (tournament_id, stage, name, sort_order, starts_at, ends_at) values
  ((select id from tournament), 'group', 'Group Stage', 1, '2026-06-11 18:00:00+00', '2026-06-27 23:00:00+00'),
  ((select id from tournament), 'round_of_16', 'Round of 16', 2, '2026-06-28 18:00:00+00', '2026-07-03 23:00:00+00'),
  ((select id from tournament), 'quarter_final', 'Quarter-finals', 3, '2026-07-04 18:00:00+00', '2026-07-07 23:00:00+00'),
  ((select id from tournament), 'semi_final', 'Semi-finals', 4, '2026-07-10 18:00:00+00', '2026-07-11 23:00:00+00'),
  ((select id from tournament), 'final', 'Final', 5, '2026-07-19 19:00:00+00', '2026-07-19 23:00:00+00')
on conflict (tournament_id, stage) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  starts_at = excluded.starts_at,
  ends_at = excluded.ends_at;

with tournament as (select id from public.tournaments where slug = 'world-cup-2026'),
round as (select id from public.rounds where tournament_id = (select id from tournament) and stage = 'group')
insert into public.matches (tournament_id, round_id, home_team_id, away_team_id, match_number, venue, city, kickoff_at)
select (select id from tournament), (select id from round), home.id, away.id, seeded.match_number, seeded.venue, seeded.city, seeded.kickoff_at::timestamptz
from (values
  (1, 'BRA'::char(3), 'FRA'::char(3), 'MetLife Stadium', 'New York/New Jersey', '2026-06-11 20:00:00+00'),
  (2, 'ARG'::char(3), 'ENG'::char(3), 'AT&T Stadium', 'Dallas', '2026-06-12 20:00:00+00'),
  (3, 'ESP'::char(3), 'GER'::char(3), 'SoFi Stadium', 'Los Angeles', '2026-06-13 20:00:00+00'),
  (4, 'POR'::char(3), 'USA'::char(3), 'Lumen Field', 'Seattle', '2026-06-14 20:00:00+00')
) as seeded(match_number, home_code, away_code, venue, city, kickoff_at)
join public.teams home on home.fifa_code = seeded.home_code
join public.teams away on away.fifa_code = seeded.away_code
on conflict (tournament_id, match_number) do update set
  round_id = excluded.round_id,
  home_team_id = excluded.home_team_id,
  away_team_id = excluded.away_team_id,
  venue = excluded.venue,
  city = excluded.city,
  kickoff_at = excluded.kickoff_at;

insert into public.achievements (slug, name, description, icon, points, criteria) values
  ('perfect-score', 'Perfect Score', 'Predict the exact score of a match.', 'target', 25, '{"exact_scores": 1}'::jsonb),
  ('hot-streak', 'Hot Streak', 'Correctly predict five outcomes in a row.', 'flame', 50, '{"correct_outcome_streak": 5}'::jsonb),
  ('early-analyst', 'Early Analyst', 'Submit predictions before the opening match locks.', 'sparkles', 10, '{"before_tournament_lock": true}'::jsonb),
  ('league-champion', 'League Champion', 'Finish first in a private league leaderboard.', 'trophy', 100, '{"league_rank": 1}'::jsonb)
on conflict (slug) do update set
  name = excluded.name,
  description = excluded.description,
  icon = excluded.icon,
  points = excluded.points,
  criteria = excluded.criteria;

commit;
