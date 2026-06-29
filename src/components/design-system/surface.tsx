import type { HTMLAttributes } from "react";
import { cn } from "@/lib/utils";

const variants = {
  glass:
    "border bg-card/72 shadow-[0_24px_80px_rgba(0,0,0,0.24)] backdrop-blur-2xl",
  solid: "border bg-card shadow-[0_20px_60px_rgba(0,0,0,0.18)]",
  gradient:
    "border bg-[linear-gradient(135deg,rgba(56,189,248,0.16),rgba(15,23,42,0.82)_45%,rgba(250,204,21,0.08))] shadow-[0_32px_120px_rgba(56,189,248,0.18)] backdrop-blur-2xl",
};

export function Surface({
  className,
  variant = "glass",
  ...props
}: HTMLAttributes<HTMLDivElement> & { variant?: keyof typeof variants }) {
  return (
    <div
      className={cn("rounded-3xl p-6", variants[variant], className)}
      {...props}
    />
  );
}
