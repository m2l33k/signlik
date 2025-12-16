"use client";

import React, { useCallback, useEffect, useMemo, useRef, useState } from "react";
import styles from "./page.module.css";
import { VideoFeed } from "@/components/VideoFeed";
import { GestureOutput } from "@/components/GestureOutput";
import { SpeechButton } from "@/components/SpeechButton";
import { useHandsLandmarks } from "@/hooks/useHandsLandmarks";
import { useGestureClassifier } from "@/hooks/useGestureClassifier";
import { speakText, isSpeechSupported } from "@/services/speech";
import { GESTURE_LABELS } from "@/utils/labels";
import { useWsPredictions } from "@/hooks/useWsPredictions";

export default function HomePage(): JSX.Element {
  const [autoSpeak, setAutoSpeak] = useState<boolean>(true);
  const { videoRef, error: handsError, landmarks } = useHandsLandmarks();
  const { modelStatus, predictGestureIndex } = useGestureClassifier();
  const [detectedIndex, setDetectedIndex] = useState<number | null>(null);
  const lastSpokenRef = useRef<string>("");
  const [wsEnabled, setWsEnabled] = useState<boolean>(false);
  const { prediction: wsPred, status: wsStatus } = useWsPredictions(wsEnabled ? "ws://localhost:8765" : null);

  const detectedWord = useMemo(() => {
    if (detectedIndex == null || detectedIndex < 0) return "";
    return GESTURE_LABELS[detectedIndex] ?? "";
  }, [detectedIndex]);

  const handleFrame = useCallback(async () => {
    if (!landmarks) return;
    try {
      const idx = await predictGestureIndex(landmarks);
      setDetectedIndex(idx);
    } catch (err) {
      // swallow prediction errors frame-by-frame to keep UI responsive
    }
  }, [landmarks, predictGestureIndex]);

  useEffect(() => {
    if (wsPred) {
      setDetectedIndex(wsPred.index);
      return;
    }
  }, [wsPred]);

  useEffect(() => {
    // speak when the detected word changes
    if (!autoSpeak || !isSpeechSupported()) return;
    if (!detectedWord) return;
    if (detectedWord && detectedWord !== lastSpokenRef.current) {
      speakText(detectedWord);
      lastSpokenRef.current = detectedWord;
    }
  }, [autoSpeak, detectedWord]);

  useEffect(() => {
    // request animation loop to handle predictions
    let rafId: number;
    const loop = () => {
      void handleFrame();
      rafId = requestAnimationFrame(loop);
    };
    rafId = requestAnimationFrame(loop);
    return () => cancelAnimationFrame(rafId);
  }, [handleFrame]);

  return (
      <main className={styles.main}>
      <div className={styles.container}>
        <div className={styles.headerRow}>
          <h1 className={styles.title}>Gesture AI</h1>
          <div className={styles.status}>
            <span className={styles.badge} title="MediaPipe Hands">
              {handsError ? "Hands Error" : "Hands Ready"}
            </span>
            <span className={styles.badge} title="TF.js Model">
              {modelStatus}
            </span>
            <span className={styles.badge} title="Python WS">
              {wsStatus}
            </span>
            <label className={styles.toggle}>
              <input
                type="checkbox"
                checked={autoSpeak}
                onChange={(e) => setAutoSpeak(e.target.checked)}
              />
              Auto speak
            </label>
            <label className={styles.toggle}>
              <input
                type="checkbox"
                checked={wsEnabled}
                onChange={(e) => setWsEnabled(e.target.checked)}
              />
              Use Python predictions
            </label>
          </div>
        </div>

        <GestureOutput word={detectedWord} />

        <div className={styles.contentRow}>
          <VideoFeed videoRef={videoRef} />
          <div className={styles.sidePanel}>
            <SpeechButton text={detectedWord} disabled={!detectedWord} />
            <div className={styles.hint}>
              Try gestures: {GESTURE_LABELS.join(", ")}
            </div>
          </div>
        </div>
        </div>
      </main>
  );
}

 
