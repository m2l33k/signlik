import asyncio
import json
from pathlib import Path

import cv2
import numpy as np
import tensorflow as tf
import websockets

MODEL_PATH = Path("models/asl_alphabet_model.h5")
IMG_SIZE = (200, 200)
HOST = "localhost"
PORT = 8765


def preprocess(frame_bgr: np.ndarray) -> np.ndarray:
    img = cv2.resize(frame_bgr, IMG_SIZE)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = img.astype("float32") / 255.0
    return img


async def stream_predictions(websocket):
    model = tf.keras.models.load_model(MODEL_PATH)
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        await websocket.send(json.dumps({"type": "error", "message": "Cannot open webcam"}))
        return

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            img = preprocess(frame)
            inp = np.expand_dims(img, axis=0)
            preds = model.predict(inp, verbose=0)[0]
            cls_idx = int(np.argmax(preds))
            conf = float(np.max(preds))
            await websocket.send(json.dumps({"type": "prediction", "index": cls_idx, "confidence": conf}))
            await asyncio.sleep(0.03)
    finally:
        cap.release()


async def handler(websocket):
    await stream_predictions(websocket)


async def main():
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model not found at {MODEL_PATH}")
    async with websockets.serve(handler, HOST, PORT):
        print(f"WebSocket server at ws://{HOST}:{PORT}")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())



