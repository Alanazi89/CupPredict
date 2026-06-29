import type { Prediction } from "@/types/prediction";

export async function getPredictions(): Promise<Prediction[]> {
  return [
    { team: "Brazil", probability: 22, form: 91, xg: 2.4 },
    { team: "France", probability: 19, form: 88, xg: 2.2 },
    { team: "Argentina", probability: 16, form: 85, xg: 2.0 },
    { team: "England", probability: 13, form: 81, xg: 1.8 },
  ];
}
