"use client";

import type { ReactElement } from "react";
import { ResponsiveContainer } from "recharts";
import { Badge } from "@/components/ui/badge";
import { Surface } from "@/components/design-system/surface";
import { Typography } from "@/components/design-system/typography";

export function ChartCard({
  title,
  eyebrow,
  delta,
  children,
}: {
  title: string;
  eyebrow?: string;
  delta?: string;
  children: ReactElement;
}) {
  return (
    <Surface className="space-y-5">
      <div className="flex items-start justify-between gap-4">
        <div className="space-y-1">
          {eyebrow ? (
            <Typography variant="caption">{eyebrow}</Typography>
          ) : null}
          <Typography variant="title">{title}</Typography>
        </div>
        {delta ? <Badge variant="success">{delta}</Badge> : null}
      </div>
      <div className="h-72 w-full">
        <ResponsiveContainer>{children}</ResponsiveContainer>
      </div>
    </Surface>
  );
}
