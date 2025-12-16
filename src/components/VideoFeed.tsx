"use client";

import React, { RefObject } from "react";

type Props = {
  videoRef: RefObject<HTMLVideoElement>;
};

export const VideoFeed: React.FC<Props> = ({ videoRef }) => {
  return (
    <div style={{ position: "relative", width: "100%", borderRadius: 12, overflow: "hidden", border: "1px solid #1f2937", background: "#000" }}>
      <video
        ref={videoRef}
        autoPlay
        muted
        playsInline
        style={{ display: "block", width: "100%", height: "auto" }}
      />
    </div>
  );
};


