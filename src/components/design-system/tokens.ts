export const designTokens = {
  typography: {
    display: "text-5xl font-black tracking-[-0.04em] md:text-7xl",
    headline: "text-3xl font-bold tracking-[-0.03em] md:text-5xl",
    title: "text-xl font-semibold tracking-[-0.02em]",
    body: "text-base leading-7 text-muted-foreground",
    caption:
      "text-xs font-medium uppercase tracking-[0.18em] text-muted-foreground",
  },
  spacing: {
    shell: "mx-auto max-w-7xl px-6 lg:px-8",
    section: "py-16 md:py-24",
    stack: "space-y-6",
  },
  radius: {
    sm: "rounded-lg",
    md: "rounded-xl",
    lg: "rounded-2xl",
    xl: "rounded-3xl",
    full: "rounded-full",
  },
  elevation: {
    card: "shadow-[0_24px_80px_rgba(0,0,0,0.24)]",
    floating: "shadow-[0_32px_120px_rgba(56,189,248,0.18)]",
    inset: "shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]",
  },
  animation: {
    enter: "animate-in fade-in slide-in-from-bottom-3 duration-500",
    hover: "transition duration-300 hover:-translate-y-0.5",
  },
} as const;

export type DesignTokenGroup = keyof typeof designTokens;
