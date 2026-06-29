import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

export type BracketMatch = {
  id: string;
  round: string;
  home: string;
  away: string;
  winner?: string;
  probability?: number;
};

export function TournamentBracket({
  matches,
  className,
}: {
  matches: BracketMatch[];
  className?: string;
}) {
  const rounds = [...new Set(matches.map((match) => match.round))];
  return (
    <div
      className={cn(
        "grid gap-4 overflow-x-auto md:grid-flow-col md:auto-cols-fr",
        className,
      )}
      aria-label="Tournament bracket"
    >
      {rounds.map((round) => (
        <section key={round} className="min-w-64 space-y-3">
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-muted-foreground">
            {round}
          </p>
          {matches
            .filter((match) => match.round === round)
            .map((match) => (
              <article
                key={match.id}
                className="rounded-2xl border bg-card/80 p-4 shadow-[0_16px_48px_rgba(0,0,0,0.16)]"
              >
                <TeamRow
                  team={match.home}
                  active={match.winner === match.home}
                />
                <div className="my-2 border-t" />
                <TeamRow
                  team={match.away}
                  active={match.winner === match.away}
                />
                {match.probability ? (
                  <Badge className="mt-3" variant="neutral">
                    {match.probability}% confidence
                  </Badge>
                ) : null}
              </article>
            ))}
        </section>
      ))}
    </div>
  );
}

function TeamRow({ team, active }: { team: string; active: boolean }) {
  return (
    <div
      className={cn(
        "flex items-center justify-between text-sm",
        active && "font-bold text-primary",
      )}
    >
      <span>{team}</span>
      <span aria-hidden>{active ? "●" : "○"}</span>
    </div>
  );
}
