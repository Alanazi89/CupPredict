import type { Metadata, Viewport } from "next";
import type { ReactNode } from "react";
import { Geist } from "next/font/google";
import "@/styles/globals.css";
import { Footer } from "@/components/layout/footer";
import { Navigation } from "@/components/layout/navigation";
import { Providers } from "@/components/layout/providers";
import { env } from "@/lib/env";

const geist = Geist({ subsets: ["latin"], variable: "--font-geist-sans" });

export const viewport: Viewport = {
  themeColor: "#070a12",
  colorScheme: "dark",
};

export const metadata: Metadata = {
  metadataBase: new URL(env.NEXT_PUBLIC_SITE_URL),
  title: {
    default: "CupPredict — World Cup forecasting",
    template: "%s | CupPredict",
  },
  description:
    "Production-grade football tournament forecasts, scenario modeling, and explainable analytics.",
  applicationName: env.NEXT_PUBLIC_APP_NAME,
  keywords: ["World Cup", "football predictions", "analytics", "forecasting"],
  authors: [{ name: "CupPredict" }],
  creator: "CupPredict",
  openGraph: {
    title: "CupPredict",
    description: "Explainable World Cup forecasting dashboards.",
    url: "/",
    siteName: "CupPredict",
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: "CupPredict dashboard",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "CupPredict",
    description: "Explainable World Cup forecasting dashboards.",
    images: ["/opengraph-image"],
  },
  icons: { icon: "/favicon.svg", apple: "/apple-icon.svg" },
  manifest: "/manifest.webmanifest",
};

export default function RootLayout({
  children,
}: Readonly<{ children: ReactNode }>) {
  return (
    <html lang="en" className="dark" suppressHydrationWarning>
      <body className={`${geist.variable} antialiased`}>
        <Providers>
          <Navigation />
          <main>{children}</main>
          <Footer />
        </Providers>
      </body>
    </html>
  );
}
