"use client";

import { useEffect, useRef, useState } from "react";

type Pred = { index: number; confidence: number } | null;

export function useWsPredictions(url: string | null) {
  const wsRef = useRef<WebSocket | null>(null);
  const [prediction, setPrediction] = useState<Pred>(null);
  const [status, setStatus] = useState<string>("WS: idle");

  useEffect(() => {
    if (!url) return;
    const ws = new WebSocket(url);
    wsRef.current = ws;
    setStatus("WS: connecting…");

    ws.onopen = () => setStatus("WS: connected");
    ws.onerror = () => setStatus("WS: error");
    ws.onclose = () => setStatus("WS: closed");
    ws.onmessage = (ev) => {
      try {
        const msg = JSON.parse(ev.data as string);
        if (msg?.type === "prediction") {
          setPrediction({ index: msg.index, confidence: msg.confidence });
        }
      } catch {}
    };

    return () => {
      ws.close();
      wsRef.current = null;
    };
  }, [url]);

  return { prediction, status } as const;
}



