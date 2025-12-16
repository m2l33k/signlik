"use client";

import React from "react";

type Props = {
  word: string;
};

export const GestureOutput: React.FC<Props> = ({ word }) => {
  return (
    <div
      style={{
        marginBottom: 16,
        padding: 16,
        borderRadius: 12,
        border: "1px solid #1f2937",
        background: "#111827",
      }}
    >
      <div style={{ opacity: 0.7, fontSize: 12, marginBottom: 6 }}>Detected word</div>
      <div style={{ fontSize: 20, minHeight: 28 }}>{word || "…"}</div>
    </div>
  );
};


