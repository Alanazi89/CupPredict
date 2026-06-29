"use client";

import {
  Bar,
  BarChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import type { Prediction } from "@/types/prediction";

export function PredictionChart({ data }: { data: Prediction[] }) {
  return (
    <div className="h-72 w-full" aria-label="World cup win probability chart">
      <ResponsiveContainer>
        <BarChart data={data}>
          <XAxis dataKey="team" stroke="#94a3b8" />
          <YAxis stroke="#94a3b8" />
          <Tooltip
            cursor={{ fill: "rgba(56,189,248,0.08)" }}
            contentStyle={{
              background: "#0f172a",
              border: "1px solid #263244",
              borderRadius: 12,
            }}
          />
          <Bar dataKey="probability" fill="#38bdf8" radius={[8, 8, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
