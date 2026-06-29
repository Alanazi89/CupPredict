import { cva, type VariantProps } from "class-variance-authority";
import type { HTMLAttributes } from "react";
import { cn } from "@/lib/utils";

const cardVariants = cva(
  "rounded-3xl border text-card-foreground backdrop-blur-2xl",
  {
    variants: {
      variant: {
        default: "bg-card/80 shadow-[0_24px_80px_rgba(0,0,0,0.24)]",
        premium:
          "bg-[linear-gradient(135deg,rgba(56,189,248,0.16),rgba(15,23,42,0.86)_48%,rgba(250,204,21,0.08))] shadow-[0_32px_120px_rgba(56,189,248,0.18)]",
        flat: "bg-card/60 shadow-none",
      },
      padding: { none: "p-0", sm: "p-4", default: "p-6", lg: "p-8" },
    },
    defaultVariants: { variant: "default", padding: "default" },
  },
);

export function Card({
  className,
  variant,
  padding,
  ...props
}: HTMLAttributes<HTMLDivElement> & VariantProps<typeof cardVariants>) {
  return (
    <div
      className={cn(cardVariants({ variant, padding }), className)}
      {...props}
    />
  );
}

export { cardVariants };
