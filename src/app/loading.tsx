import { Skeleton } from "@/components/ui/skeleton";

export default function Loading() {
  return (
    <div className="mx-auto max-w-7xl space-y-6 px-6 py-20">
      <Skeleton className="h-16 w-2/3" />
      <Skeleton className="h-96" />
    </div>
  );
}
