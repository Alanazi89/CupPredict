import Link from "next/link";
import { Trophy } from "lucide-react";
import { Button } from "@/components/ui/button";

const links = ["Predictions", "Simulator", "Insights"];

export function Navigation() {
  return (
    <header className="sticky top-0 z-50 border-b bg-background/80 backdrop-blur-xl">
      <nav
        className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4"
        aria-label="Primary navigation"
      >
        <Link href="/" className="flex items-center gap-2 font-bold">
          <Trophy className="size-6 text-primary" />
          CupPredict
        </Link>
        <div className="hidden items-center gap-6 md:flex">
          {links.map((link) => (
            <a
              key={link}
              href={`#${link.toLowerCase()}`}
              className="text-sm text-muted-foreground hover:text-foreground"
            >
              {link}
            </a>
          ))}
        </div>
        <Button asChild size="sm">
          <a href="#simulator">Run model</a>
        </Button>
      </nav>
    </header>
  );
}
