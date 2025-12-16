"""
Train TSL model using available data (ASL dataset as test, or synthetic data).
This allows testing the training pipeline before TSL dataset is available.
"""

import json
import numpy as np
import tensorflow as tf
from pathlib import Path
from typing import List, Tuple, Optional
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
import cv2
import mediapipe as mp

# Try to use ASL dataset if TSL not available
ASL_DATASET_DIR = Path("../dataset/asl_alphabet_kaggle")
TSL_DATASET_DIR = Path("../dataset/tsl_dataset/organized")
OUTPUT_DIR = Path("../models")
NUM_CLASSES = 57
LANDMARK_DIM = 42

TSL_SIGNS = [
    "hello", "goodbye", "thank_you", "please", "sorry",
    "yes", "no", "maybe", "ok", "help",
    "mother", "father", "brother", "sister", "family",
    "water", "food", "eat", "drink", "sleep",
    "house", "school", "work", "home", "friend",
    "today", "tomorrow", "yesterday", "morning", "evening",
    "what", "where", "when", "why", "how", "who",
    "go", "come", "see", "hear", "speak",
    "read", "write", "learn", "teach", "understand",
    "zero", "one", "two", "three", "four",
    "five", "six", "seven", "eight", "nine",
    "good", "bad", "happy", "sad", "love", "like", "want", "need"
]


def extract_landmarks_from_image(image_path: Path, hand_landmarker) -> Optional[np.ndarray]:
    """Extract normalized landmarks from an image."""
    image = cv2.imread(str(image_path))
    if image is None:
        return None
    
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hand_landmarker.process(image_rgb)
    
    if not results.hand_landmarks or len(results.hand_landmarks) == 0:
        return None
    
    landmarks = results.hand_landmarks[0]
    points = np.array([[lm.x, lm.y] for lm in landmarks.landmark])
    wrist = points[0]
    normalized = points - wrist
    
    return normalized.flatten().astype(np.float32)


def extract_from_asl_dataset(data_dir: Path, limit_classes: int = 10) -> Tuple[np.ndarray, np.ndarray, List[str]]:
    """Extract landmarks from ASL dataset as a test (maps A-Z to first N TSL signs)."""
    mp_hands = mp.solutions.hands
    hand_landmarker = mp_hands.Hands(
        static_image_mode=True,
        max_num_hands=1,
        min_detection_confidence=0.5
    )
    
    features_list = []
    labels_list = []
    
    # Map ASL letters to first N TSL signs for testing
    asl_letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
    class_mapping = {letter: idx for idx, letter in enumerate(asl_letters[:limit_classes])}
    
    print(f"Using ASL dataset for testing (mapping to first {limit_classes} TSL signs)")
    
    for letter, class_idx in class_mapping.items():
        letter_dir = data_dir / letter
        if not letter_dir.exists():
            continue
        
        images = list(letter_dir.glob('*.jpg'))[:50]  # Limit per class
        print(f"Processing {len(images)} images for '{letter}' → '{TSL_SIGNS[class_idx]}'...")
        
        for img_path in images:
            features = extract_landmarks_from_image(img_path, hand_landmarker)
            if features is not None:
                features_list.append(features)
                labels_list.append(class_idx)
    
    hand_landmarker.close()
    
    if len(features_list) == 0:
        raise ValueError("No landmarks extracted from ASL dataset")
    
    X = np.array(features_list)
    y = np.array(labels_list)
    
    class_names = [TSL_SIGNS[i] for i in range(limit_classes)]
    
    return X, y, class_names


def generate_synthetic_data(n_samples: int = 2000, n_classes: int = 10) -> Tuple[np.ndarray, np.ndarray, List[str]]:
    """Generate synthetic landmark data for testing."""
    print(f"Generating {n_samples} synthetic samples for {n_classes} classes...")
    
    # Generate realistic landmark patterns
    X = []
    y = []
    
    for class_idx in range(n_classes):
        samples_per_class = n_samples // n_classes
        for _ in range(samples_per_class):
            # Generate landmarks with class-specific patterns
            base_pattern = np.random.randn(21, 2).astype(np.float32) * 0.1
            # Add class-specific variation
            class_variation = np.random.randn(21, 2).astype(np.float32) * (0.05 * (class_idx + 1))
            landmarks = base_pattern + class_variation
            
            # Normalize relative to wrist
            landmarks[0] = [0.0, 0.0]  # Wrist at origin
            normalized = landmarks.flatten()
            
            X.append(normalized)
            y.append(class_idx)
    
    X = np.array(X)
    y = np.array(y)
    class_names = [TSL_SIGNS[i] for i in range(n_classes)]
    
    return X, y, class_names


def augment_data(X: np.ndarray, y: np.ndarray, factor: int = 3) -> Tuple[np.ndarray, np.ndarray]:
    """Augment data."""
    augmented_X = [X]
    augmented_y = [y]
    
    for _ in range(factor):
        # Noise
        noise = np.random.normal(0, 0.01, X.shape).astype(np.float32)
        augmented_X.append(X + noise)
        augmented_y.append(y)
        
        # Scaling
        for scale in [0.95, 1.05]:
            augmented_X.append(X * scale)
            augmented_y.append(y)
    
    return np.vstack(augmented_X), np.hstack(augmented_y)


def build_model(input_dim: int, num_classes: int) -> tf.keras.Model:
    """Build model."""
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(input_dim,)),
        tf.keras.layers.Dense(256, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.4),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model


def main():
    """Main training function."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print("="*60)
    print("TSL Model Training (Using Available Data)")
    print("="*60)
    
    # Try to get data
    X, y, class_names = None, None, None
    
    # Try TSL dataset first
    if TSL_DATASET_DIR.exists() and any(TSL_DATASET_DIR.iterdir()):
        print("\nUsing TSL dataset...")
        print("Please use train_tsl_enhanced.py when TSL dataset is ready")
        # Continue with fallback for testing
        pass
    
    # Try ASL dataset as test
    if X is None and ASL_DATASET_DIR.exists():
        try:
            print("\nUsing ASL dataset for testing (proof of concept)...")
            X, y, class_names = extract_from_asl_dataset(ASL_DATASET_DIR, limit_classes=10)
            print(f"✓ Extracted {len(X)} samples from ASL dataset")
        except Exception as e:
            print(f"⚠ Could not use ASL dataset: {e}")
            X, y, class_names = None, None, None
    
    # Fallback to synthetic
    if X is None:
        print("\nUsing synthetic data for pipeline testing...")
        X, y, class_names = generate_synthetic_data(n_samples=2000, n_classes=10)
        print(f"✓ Generated {len(X)} synthetic samples")
    
    # Augment
    print("\nAugmenting data...")
    X_aug, y_aug = augment_data(X, y, factor=2)
    print(f"  Augmented to {len(X_aug)} samples")
    
    # Split
    X_train, X_temp, y_train, y_temp = train_test_split(
        X_aug, y_aug, test_size=0.3, random_state=42, stratify=y_aug
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
    )
    
    print(f"\nData split:")
    print(f"  Train: {len(X_train)}")
    print(f"  Val: {len(X_val)}")
    print(f"  Test: {len(X_test)}")
    
    # Build and train
    print("\nBuilding model...")
    model = build_model(LANDMARK_DIM, len(class_names))
    
    print("\nTraining model...")
    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True),
        tf.keras.callbacks.ModelCheckpoint(
            str(OUTPUT_DIR / 'tsl_model.h5'),
            monitor='val_loss',
            save_best_only=True
        )
    ]
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=50,
        batch_size=32,
        callbacks=callbacks,
        verbose=1
    )
    
    model.load_weights(OUTPUT_DIR / 'tsl_model.h5')
    
    # Evaluate
    test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
    print(f"\n{'='*60}")
    print("Test Results:")
    print(f"  Accuracy: {test_acc:.4f} ({test_acc*100:.2f}%)")
    print(f"{'='*60}")
    
    # Save
    with open(OUTPUT_DIR / 'tsl_model_classes.json', 'w') as f:
        json.dump(class_names, f, indent=2)
    
    print(f"\n✓ Model saved to: {OUTPUT_DIR / 'tsl_model.h5'}")
    print("Note: This is a test model. Train with TSL dataset for production.")


if __name__ == "__main__":
    main()

