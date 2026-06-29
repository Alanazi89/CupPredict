import { Suspense } from "react";
import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { getPredictions } from "@/services/predictions";
import { formatPercent } from "@/utils/format";
import { PredictionChart } from "./prediction-chart";
import { SimulatorForm } from "./simulator-form";

export async function PredictionsDashboard() {
  const predictions = await getPredictions();
  return (
    <section
      id="predictions"
      className="mx-auto grid max-w-7xl gap-6 px-6 py-16 lg:grid-cols-[1.2fr_0.8fr]"
    >
      <Card>
        <div className="mb-6 flex items-center justify-between">
          <h2 className="text-2xl font-bold">Live title probabilities</h2>
          <span className="text-sm text-muted-foreground">Model v1.0</span>
        </div>
        <Suspense fallback={<Skeleton className="h-72" />}>
          <PredictionChart data={predictions} />
        </Suspense>
      </Card>
      <Card id="simulator">
        <h2 className="mb-4 text-2xl font-bold">Scenario simulator</h2>
        <SimulatorForm />
      </Card>
      <div id="insights" className="grid gap-4 lg:col-span-2 md:grid-cols-4">
        {predictions.map((prediction) => (
          <Card key={prediction.team} className="p-5">
            <p className="text-sm text-muted-foreground">{prediction.team}</p>
            <p className="mt-2 text-3xl font-bold">
              {formatPercent(prediction.probability)}
            </p>
            <p className="mt-2 text-sm text-muted-foreground">
              Form {prediction.form} · xG {prediction.xg}
            </p>
          </Card>
        ))}
      </div>
    </section>
  );
}
