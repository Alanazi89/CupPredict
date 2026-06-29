export function Footer() {
  return (
    <footer className="border-t py-8">
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-6 text-sm text-muted-foreground md:flex-row md:items-center md:justify-between">
        <p>
          © {new Date().getFullYear()} CupPredict. Forecasts for planning, not
          guarantees.
        </p>
        <a className="hover:text-foreground" href="mailto:hello@cuppredict.app">
          hello@cuppredict.app
        </a>
      </div>
    </footer>
  );
}
