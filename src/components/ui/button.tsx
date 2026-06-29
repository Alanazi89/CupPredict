import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import type { ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-xl text-sm font-semibold tracking-[-0.01em] transition-all duration-300 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/20 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow-[0_16px_48px_rgba(56,189,248,0.26)] hover:-translate-y-0.5 hover:opacity-95",
        secondary:
          "border bg-muted/80 text-foreground shadow-[inset_0_1px_0_rgba(255,255,255,0.06)] hover:bg-muted",
        ghost: "text-muted-foreground hover:bg-muted hover:text-foreground",
        premium:
          "bg-[linear-gradient(135deg,#f8fafc,#38bdf8_48%,#facc15)] text-slate-950 shadow-[0_20px_80px_rgba(56,189,248,0.34)] hover:-translate-y-0.5",
        destructive:
          "bg-red-500 text-white shadow-[0_16px_48px_rgba(239,68,68,0.22)] hover:bg-red-400",
      },
      size: {
        sm: "h-9 px-3",
        default: "h-11 px-5",
        lg: "h-12 px-7 text-base",
        icon: "size-11 p-0",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  },
);

export interface ButtonProps
  extends
    ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

export function Button({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: ButtonProps) {
  const Comp = asChild ? Slot : "button";
  return (
    <Comp
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}

export { buttonVariants };
