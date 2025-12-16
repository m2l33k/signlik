import time
from pathlib import Path
from typing import Tuple

import cv2
import numpy as np
import tensorflow as tf

MODEL_PATH = Path("models/asl_alphabet_model.h5")
IMG_SIZE = (200, 200)


def preprocess(frame_bgr: np.ndarray) -> np.ndarray:
    img = cv2.resize(frame_bgr, IMG_SIZE)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = img.astype("float32") / 255.0
    return img


def main() -> None:
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model not found at {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH)
    class_names = model.output_shape[-1]
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        raise RuntimeError("Cannot open webcam")

    print("Press 'q' to quit.")
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        img = preprocess(frame)
        inp = np.expand_dims(img, axis=0)
        preds = model.predict(inp, verbose=0)[0]
        cls_idx = int(np.argmax(preds))
        conf = float(np.max(preds))
        text = f"Pred: {cls_idx} ({conf:.2f})"

        cv2.putText(frame, text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
        cv2.imshow("ASL Predict", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()



