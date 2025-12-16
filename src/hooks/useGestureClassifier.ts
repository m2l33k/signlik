"use client";

import * as tf from "@tensorflow/tfjs";
import { useCallback, useEffect, useRef, useState } from "react";
import type { Point2D } from "./useHandsLandmarks";

const MODEL_PATH = "/gesture-model/model.json"; // served from public

export function useGestureClassifier() {
  const [modelStatus, setModelStatus] = useState<string>("Loading model…");
  const modelRef = useRef<tf.LayersModel | null>(null);
  const probBufferRef = useRef<number[][]>([]); // smoothing buffer of recent probs
  const maxBuffer = 8; // number of frames to smooth over

  useEffect(() => {
    let cancelled = false;
    const load = async () => {
      try {
        await tf.ready();
        // prefer WebGL, fallback to WASM/CPU
        try {
          await tf.setBackend("webgl");
        } catch {
          try {
            await tf.setBackend("wasm");
          } catch {
            await tf.setBackend("cpu");
          }
        }
        await tf.ready();
        const model = await tf.loadLayersModel(MODEL_PATH);
        if (!cancelled) {
          modelRef.current = model;
          setModelStatus("Model Ready");
        }
      } catch (err) {
        if (cancelled) return;
        setModelStatus("Model Fallback (random)");
        modelRef.current = null;
      }
    };
    void load();
    return () => {
      cancelled = true;
      if (modelRef.current) {
        modelRef.current = null;
      }
    };
  }, []);

  const predictGestureIndex = useCallback(async (points: Point2D[] | null) => {
    // 21 points * (x,y) => 42 features; normalize simple center relative to wrist (index 0)
    if (!points || points.length < 21) return -1;
    const base = points[0];
    const features = new Float32Array(42);
    for (let i = 0; i < 21; i++) {
      const px = points[i].x - base.x;
      const py = points[i].y - base.y;
      features[i * 2] = px;
      features[i * 2 + 1] = py;
    }
    const model = modelRef.current;
    if (!model) {
      // fallback: deterministic pseudo class based on simple heuristic
      const sum = features.reduce((a, b) => a + Math.abs(b), 0);
      return Math.max(0, Math.min(4, Math.floor(sum * 10) % 5));
    }
    const input = tf.tensor2d(features, [1, 42]);
    const logits = model.predict(input) as tf.Tensor;
    const probs = await tf.softmax(logits).data();
    input.dispose();
    logits.dispose();

    // push to smoothing buffer
    const buf = probBufferRef.current;
    buf.push(Array.from(probs));
    if (buf.length > maxBuffer) buf.shift();
    // average probs across buffer
    const avg = new Array(probs.length).fill(0);
    for (const row of buf) {
      for (let i = 0; i < row.length; i++) avg[i] += row[i];
    }
    for (let i = 0; i < avg.length; i++) avg[i] /= buf.length;

    // thresholding to avoid jitter
    let maxI = 0;
    for (let i = 1; i < avg.length; i++) if (avg[i] > avg[maxI]) maxI = i;
    const confidence = avg[maxI];
    const MIN_CONFIDENCE = 0.55; // tune as needed
    if (confidence < MIN_CONFIDENCE) return -1; // treat as no confident gesture
    return maxI;
  }, []);

  return { modelStatus, predictGestureIndex } as const;
}


