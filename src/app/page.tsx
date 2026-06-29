import { ArrowRight, ShieldCheck, Sparkles } from "lucide-react";
import { Suspense } from "react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { PredictionsDashboard } from "@/features/predictions/components/predictions-dashboard";

export default function Home() {
  return (
    <>
      <section className="mx-auto grid max-w-7xl gap-10 px-6 py-20 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
        <div>
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border bg-card px-4 py-2 text-sm text-muted-foreground">
            <Sparkles className="size-4 text-primary" /> AI-assisted tournament
            intelligence
          </div>
          <h1 className="text-5xl font-black tracking-tight md:text-7xl">
            Predict the cup before the first whistle.
          </h1>
          <p className="mt-6 max-w-2xl text-lg text-muted-foreground">
            CupPredict combines team strength, form, expected goals, travel
            fatigue, and scenario planning in a production-ready Next.js
            platform.
          </p>
          <div className="mt-8 flex flex-col gap-3 sm:flex-row">
            <Button asChild size="lg">
              <a href="#predictions">
                Explore predictions <ArrowRight className="size-4" />
              </a>
            </Button>
            <Button asChild variant="secondary" size="lg">
              <a href="#insights">View insights</a>
            </Button>
          </div>
        </div>
        <div className="rounded-3xl border bg-card/70 p-8 shadow-2xl shadow-sky-500/10">
          <ShieldCheck className="mb-6 size-12 text-primary" />
          <h2 className="text-2xl font-bold">Built for resilient launches</h2>
          <p className="mt-3 text-muted-foreground">
            Typed config, validated environment variables, accessible
            components, loading states, error boundaries, and streaming-ready
            Suspense surfaces.
          </p>
        </div>
      </section>
      <Suspense
        fallback={
          <div className="mx-auto max-w-7xl px-6">
            <Skeleton className="h-96" />
          </div>
        }
      >
        <PredictionsDashboard />
      </Suspense>
    </>
  );
}
