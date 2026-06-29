import { Badge } from "@/components/ui/badge";
import { Surface } from "@/components/design-system/surface";
import { cn } from "@/lib/utils";

export type LeaderboardEntry = {
  rank: number;
  label: string;
  value: string;
  meta?: string;
  trend?: "up" | "down" | "flat";
};

const trendCopy = { up: "↗", down: "↘", flat: "→" } as const;

export function LeaderboardCard({
  title,
  entries,
  className,
}: {
  title: string;
  entries: LeaderboardEntry[];
  className?: string;
}) {
  return (
    <Surface className={cn("space-y-4", className)}>
      <div className="flex items-center justify-between">
        <h3 className="text-xl font-semibold tracking-[-0.02em]">{title}</h3>
        <Badge variant="neutral">Top {entries.length}</Badge>
      </div>
      <ol className="space-y-3">
        {entries.map((entry) => (
          <li
            key={`${entry.rank}-${entry.label}`}
            className="flex items-center gap-4 rounded-2xl border bg-background/40 p-3"
          >
            <span className="flex size-9 items-center justify-center rounded-full bg-muted text-sm font-bold">
              {entry.rank}
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate font-semibold">{entry.label}</p>
              {entry.meta ? (
                <p className="text-sm text-muted-foreground">{entry.meta}</p>
              ) : null}
            </div>
            <div className="text-right">
              <p className="font-bold">{entry.value}</p>
              {entry.trend ? (
                <p className="text-sm text-primary">{trendCopy[entry.trend]}</p>
              ) : null}
            </div>
          </li>
        ))}
      </ol>
    </Surface>
  );
}
