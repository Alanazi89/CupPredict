"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { motion } from "framer-motion";
import { useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import {
  simulatorSchema,
  type SimulatorInput,
} from "@/features/predictions/lib/schema";

export function SimulatorForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
  } = useForm<SimulatorInput>({
    resolver: zodResolver(simulatorSchema),
    defaultValues: { favorite: "Brazil", confidence: 75 },
  });
  const confidence = watch("confidence");
  return (
    <form onSubmit={handleSubmit(() => undefined)} className="space-y-4">
      <label className="block text-sm font-medium">
        Favorite team
        <input
          className="mt-2 w-full rounded-xl border bg-background px-4 py-3"
          {...register("favorite")}
        />
      </label>
      {errors.favorite ? (
        <p className="text-sm text-red-400">{errors.favorite.message}</p>
      ) : null}
      <label className="block text-sm font-medium">
        Confidence: {confidence}%
        <input
          type="range"
          min="1"
          max="100"
          className="mt-2 w-full accent-sky-400"
          {...register("confidence")}
        />
      </label>
      <motion.div
        initial={{ opacity: 0, y: 8 }}
        animate={{ opacity: 1, y: 0 }}
        className="rounded-xl bg-muted p-4 text-sm text-muted-foreground"
      >
        Blend Elo, xG, injuries, travel, and market signals into an explainable
        forecast.
      </motion.div>
      <Button type="submit">Save scenario</Button>
    </form>
  );
}
