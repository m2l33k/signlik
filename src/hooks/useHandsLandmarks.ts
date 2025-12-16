"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { FilesetResolver, HandLandmarker, type HandLandmarkerResult } from "@mediapipe/tasks-vision";

export type Point2D = { x: number; y: number };

type UseHandsReturn = {
  videoRef: React.RefObject<HTMLVideoElement>;
  error: string | null;
  landmarks: Point2D[] | null;
};

/**
 * Initializes webcam and MediaPipe HandLandmarker to continuously detect landmarks.
 */
export function useHandsLandmarks(): UseHandsReturn {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [landmarks, setLandmarks] = useState<Point2D[] | null>(null);
  const landmarkerRef = useRef<HandLandmarker | null>(null);
  const [ready, setReady] = useState(false);

  const init = useCallback(async () => {
    try {
      // get camera
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" }, audio: false });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await new Promise((res) => videoRef.current?.addEventListener("loadedmetadata", res, { once: true }));
        await videoRef.current.play();
      }

      // load mediapipe
      const filesetResolver = await FilesetResolver.forVisionTasks(
        "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm"
      );
      const landmarker = await HandLandmarker.createFromOptions(filesetResolver, {
        baseOptions: {
          modelAssetPath:
            "https://storage.googleapis.com/mediapipe-assets/hand_landmarker.task",
        },
        numHands: 1,
        runningMode: "VIDEO",
      });
      landmarkerRef.current = landmarker;
      setReady(true);
    } catch (e: any) {
      setError(e?.message ?? "Failed to initialize camera or hand tracker");
    }
  }, []);

  useEffect(() => {
    void init();
    return () => {
      // cleanup camera
      const tracks = (videoRef.current?.srcObject as MediaStream | null)?.getTracks() ?? [];
      tracks.forEach((t) => t.stop());
      landmarkerRef.current?.close();
    };
  }, [init]);

  useEffect(() => {
    if (!ready) return;
    let rafId: number;
    const step = () => {
      const video = videoRef.current;
      const lm = landmarkerRef.current;
      if (video && lm) {
        try {
          const result: HandLandmarkerResult = lm.detectForVideo(video, performance.now());
          const first = result.landmarks?.[0];
          if (first && first.length >= 21) {
            setLandmarks(first.map((p) => ({ x: p.x, y: p.y })));
          } else {
            setLandmarks(null);
          }
        } catch {
          // ignore per-frame
        }
      }
      rafId = requestAnimationFrame(step);
    };
    rafId = requestAnimationFrame(step);
    return () => cancelAnimationFrame(rafId);
  }, [ready]);

  return { videoRef, error, landmarks };
}


