import { ImageResponse } from "next/og";

export const runtime = "edge";
export const alt = "CupPredict dashboard";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function Image() {
  return new ImageResponse(
    <div
      style={{
        background: "#070a12",
        color: "white",
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        padding: 80,
      }}
    >
      <div style={{ color: "#38bdf8", fontSize: 32 }}>CupPredict</div>
      <div style={{ fontSize: 72, fontWeight: 800 }}>
        World Cup forecasting, explained.
      </div>
    </div>,
    size,
  );
}
