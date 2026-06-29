import type { ElementType, HTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";

type TypographyVariant =
  | "eyebrow"
  | "display"
  | "headline"
  | "title"
  | "body"
  | "caption";

const variants: Record<TypographyVariant, string> = {
  eyebrow: "text-sm font-semibold uppercase tracking-[0.22em] text-primary",
  display: "text-5xl font-black tracking-[-0.04em] text-balance md:text-7xl",
  headline: "text-3xl font-bold tracking-[-0.03em] text-balance md:text-5xl",
  title: "text-xl font-semibold tracking-[-0.02em]",
  body: "text-base leading-7 text-muted-foreground",
  caption:
    "text-xs font-medium uppercase tracking-[0.18em] text-muted-foreground",
};

const elementByVariant = {
  eyebrow: "p",
  display: "h1",
  headline: "h2",
  title: "h3",
  body: "p",
  caption: "p",
} as const;

export function Typography({
  variant = "body",
  as,
  className,
  children,
  ...props
}: HTMLAttributes<HTMLElement> & {
  variant?: TypographyVariant;
  as?: ElementType;
  children: ReactNode;
}) {
  const Comp = as ?? elementByVariant[variant];
  return (
    <Comp className={cn(variants[variant], className)} {...props}>
      {children}
    </Comp>
  );
}
