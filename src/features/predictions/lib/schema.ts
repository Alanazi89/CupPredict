import { z } from "zod";

export const simulatorSchema = z.object({
  favorite: z.string().min(2, "Choose a team"),
  confidence: z.coerce.number().min(1).max(100),
});

export type SimulatorInput = z.infer<typeof simulatorSchema>;
