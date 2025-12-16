import json
import os
from pathlib import Path
from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix

DATASET_DIR = Path("./dataset/asl_alphabet_kaggle")
IMG_SIZE = (200, 200)
BATCH_SIZE = 32
EPOCHS = 50
LEARNING_RATE = 1e-4
NUM_CLASSES = 5


def build_datasets(data_dir: Path) -> Tuple[tf.data.Dataset, tf.data.Dataset, tf.data.Dataset, list[str]]:
    if not data_dir.exists():
        raise FileNotFoundError(f"Dataset directory not found: {data_dir}")

    # Load with a fixed seed for reproducibility
    ds = tf.keras.utils.image_dataset_from_directory(
        data_dir,
        labels="inferred",
        label_mode="categorical",
        image_size=IMG_SIZE,
        shuffle=True,
        seed=42,
        batch_size=BATCH_SIZE,
    )
    class_names = ds.class_names
    print(f"Available classes: {class_names}")

    # For now, let's use the first 5 classes that exist
    selected_classes = class_names[:NUM_CLASSES]
    print(f"Using first {NUM_CLASSES} classes: {selected_classes}")

    # Filter dataset to only selected classes
    def filter_classes(image, label):
        class_idx = tf.argmax(label)
        return tf.reduce_any(tf.equal(class_idx, list(range(len(selected_classes)))))

    ds = ds.filter(filter_classes)

    # Split into 80/10/10 using cardinality
    ds = ds.cache()
    total_batches = tf.data.experimental.cardinality(ds).numpy()
    print(f"Total batches after filtering: {total_batches}")

    if total_batches == 0:
        raise ValueError("No data found for selected classes!")

    train_batches = max(1, int(total_batches * 0.8))
    val_batches = max(1, int(total_batches * 0.1))

    ds_train = ds.take(train_batches)
    ds_rem = ds.skip(train_batches)
    ds_val = ds_rem.take(val_batches)
    ds_test = ds_rem.skip(val_batches)

    # Data augmentation pipeline
    aug = tf.keras.Sequential([
        tf.keras.layers.RandomFlip("horizontal"),
        tf.keras.layers.RandomRotation(0.15),
        tf.keras.layers.RandomZoom(0.1),
        tf.keras.layers.RandomBrightness(factor=0.2),
    ])

    def preprocess(images, labels):
        images = tf.cast(images, tf.float32) / 255.0
        return images, labels

    def augment(images, labels):
        images = aug(images, training=True)
        return images, labels

    autotune = tf.data.AUTOTUNE
    ds_train = ds_train.map(preprocess, num_parallel_calls=autotune).map(augment, num_parallel_calls=autotune).prefetch(autotune)
    ds_val = ds_val.map(preprocess, num_parallel_calls=autotune).prefetch(autotune)
    ds_test = ds_test.map(preprocess, num_parallel_calls=autotune).prefetch(autotune)

    return ds_train, ds_val, ds_test, selected_classes


def build_model(num_classes: int) -> tf.keras.Model:
    base = tf.keras.applications.MobileNetV2(
        input_shape=IMG_SIZE + (3,), include_top=False, weights="imagenet"
    )
    base.trainable = False  # freeze for initial training
    inputs = tf.keras.Input(shape=IMG_SIZE + (3,))
    x = tf.keras.applications.mobilenet_v2.preprocess_input(inputs)
    x = base(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dense(128, activation="relu")(x)
    x = tf.keras.layers.Dropout(0.4)(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)
    model = tf.keras.Model(inputs, outputs)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def plot_history(history: tf.keras.callbacks.History, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    hist = history.history
    # Accuracy
    plt.figure(figsize=(6,4))
    plt.plot(hist["accuracy"], label="train_acc")
    plt.plot(hist["val_accuracy"], label="val_acc")
    plt.legend(); plt.title("Accuracy"); plt.xlabel("Epoch"); plt.ylabel("Acc")
    plt.tight_layout(); plt.savefig(out_dir / "history_accuracy.png"); plt.close()
    # Loss
    plt.figure(figsize=(6,4))
    plt.plot(hist["loss"], label="train_loss")
    plt.plot(hist["val_loss"], label="val_loss")
    plt.legend(); plt.title("Loss"); plt.xlabel("Epoch"); plt.ylabel("Loss")
    plt.tight_layout(); plt.savefig(out_dir / "history_loss.png"); plt.close()


def evaluate(model: tf.keras.Model, ds_test: tf.data.Dataset, class_names: list[str], out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    loss, acc = model.evaluate(ds_test, verbose=2)
    print(f"Test accuracy: {acc:.4f}")
    with open(out_dir / "test_metrics.json", "w", encoding="utf-8") as f:
        json.dump({"loss": float(loss), "accuracy": float(acc)}, f, indent=2)

    # Predictions and classification report
    y_true = []
    y_pred = []
    for batch_images, batch_labels in ds_test:
        preds = model.predict(batch_images, verbose=0)
        y_pred.extend(np.argmax(preds, axis=1))
        y_true.extend(np.argmax(batch_labels.numpy(), axis=1))
    cm = confusion_matrix(y_true, y_pred)
    report = classification_report(y_true, y_pred, target_names=class_names, output_dict=True)
    np.save(out_dir / "confusion_matrix.npy", cm)
    with open(out_dir / "classification_report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)


def main() -> None:
    models_dir = Path("models")
    models_dir.mkdir(parents=True, exist_ok=True)

    ds_train, ds_val, ds_test, class_names = build_datasets(DATASET_DIR)
    print(f"Classes: {class_names}")

    model = build_model(num_classes=len(class_names))
    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=10, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=5),
        tf.keras.callbacks.ModelCheckpoint(filepath=str(models_dir / "asl_alphabet_model.h5"), monitor="val_loss", save_best_only=True),
    ]
    history = model.fit(
        ds_train,
        validation_data=ds_val,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=2,
    )
    plot_history(history, models_dir)

    # Load best weights and evaluate
    model.load_weights(models_dir / "asl_alphabet_model.h5")
    evaluate(model, ds_test, class_names, models_dir)


if __name__ == "__main__":
    main()



