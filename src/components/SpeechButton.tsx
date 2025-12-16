"use client";

import React from "react";
import { speakText, isSpeechSupported } from "@/services/speech";

type Props = {
  text: string;
  disabled?: boolean;
};

export const SpeechButton: React.FC<Props> = ({ text, disabled }) => {
  const canSpeak = isSpeechSupported() && !!text && !disabled;
  return (
    <button
      onClick={() => speakText(text)}
      disabled={!canSpeak}
      aria-label="Play speech"
      style={{
        display: "flex",
        alignItems: "center",
        gap: 8,
        padding: "10px 12px",
        borderRadius: 12,
        border: "1px solid #1f2937",
        background: canSpeak ? "#0ea5e9" : "#1f2937",
        color: "#fff",
        cursor: canSpeak ? "pointer" : "not-allowed",
        fontWeight: 600,
      }}
    >
      <span style={{ fontSize: 16 }}>▶</span>
      <span>Speak</span>
    </button>
  );
};


