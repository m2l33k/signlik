"""
Train a landmark-based model for Tunisian Sign Language (TSL) recognition.
Supports 57 TSL signs using MediaPipe landmarks.
"""

import json
import pickle
from pathlib import Path
from typing import List, Tuple, Optional

import cv2
import mediapipe as mp
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt

DATASET_DIR = Path("../dataset/tsl_dataset/organized")
OUTPUT_DIR = Path("../models")
NUM_CLASSES = 57  # 57 TSL signs
LANDMARK_DIM = 42  # 21 points × 2 coordinates
EPOCHS = 150
BATCH_SIZE = 32
LEARNING_RATE = 1e-3
VALIDATION_SPLIT = 0.2
TEST_SPLIT = 0.1

# TSL sign labels (57 standard signs)
TSL_SIGNS = [
    # Greetings
    "hello", "goodbye", "thank_you", "please", "sorry",
    # Basic words
    "yes", "no", "maybe", "ok", "help",
    # Family
    "mother", "father", "brother", "sister", "family",
    # Common words
    "water", "food", "eat", "drink", "sleep",
    "house", "school", "work", "home", "friend",
    # Days
    "today", "tomorrow", "yesterday", "morning", "evening",
    # Questions
    "what", "where", "when", "why", "how", "who",
    # Actions
    "go", "come", "see", "hear", "speak",
    "read", "write", "learn", "teach", "understand",
    # Numbers (0-9)
    "zero", "one", "two", "three", "four",
    "five", "six", "seven", "eight", "nine",
    # Additional
    "good", "bad", "happy", "sad", "love", "like", "want", "need"
]


def extract_landmarks_from_image(image_path: Path, hand_landmarker) -> Optional[np.ndarray]:
    """Extract normalized landmarks from an image. Returns 42-feature array or None if no hand detected."""
    image = cv2.imread(str(image_path))
    if image is None:
        return None
    
    # Convert BGR to RGB
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    # Detect hands
    results = hand_landmarker.process(image_rgb)
    
    if not results.hand_landmarks or len(results.hand_landmarks) == 0:
        return None
    
    # Use the first detected hand
    landmarks = results.hand_landmarks[0]
    
    # Extract 21 points as (x, y) coordinates
    points = []
    for landmark in landmarks.landmark:
        points.append([landmark.x, landmark.y])
    
    points = np.array(points)  # Shape: (21, 2)
    
    # Normalize relative to wrist (point 0)
    wrist = points[0]
    normalized = points - wrist
    
    # Flatten to 42 features
    features = normalized.flatten().astype(np.float32)
    
    return features


def extract_landmarks_from_dataset(data_dir: Path, max_samples_per_class: int = None) -> Tuple[np.ndarray, np.ndarray, List[str]]:
    """Extract landmarks from all images in the TSL dataset directory structure."""
    mp_hands = mp.solutions.hands
    hand_landmarker = mp_hands.Hands(
        static_image_mode=True,
        max_num_hands=1,
        min_detection_confidence=0.5
    )
    
    features_list = []
    labels_list = []
    class_names = []
    
    if not data_dir.exists():
        raise FileNotFoundError(f"Dataset directory not found: {data_dir}")
    
    # Get class directories (sign folders)
    class_dirs = [d for d in data_dir.iterdir() if d.is_dir() and not d.name.startswith('.')]
    
    if not class_dirs:
        raise ValueError(f"No class directories found in {data_dir}. Expected structure: data_dir/sign_name/*.jpg")
    
    # Sort to ensure consistent ordering
    class_dirs = sorted(class_dirs, key=lambda x: x.name)
    
    # Map directory names to class indices
    sign_to_index = {sign: idx for idx, sign in enumerate(TSL_SIGNS)}
    
    print(f"Found {len(class_dirs)} sign directories")
    print(f"Processing up to {max_samples_per_class or 'all'} samples per class...")
    
    for class_dir in class_dirs:
        sign_name = class_dir.name.lower().replace(' ', '_').replace('-', '_')
        
        # Try to match with TSL_SIGNS
        if sign_name not in sign_to_index:
            # Try fuzzy matching
            matched = False
            for tsl_sign in TSL_SIGNS:
                if tsl_sign in sign_name or sign_name in tsl_sign:
                    sign_name = tsl_sign
                    matched = True
                    break
            
            if not matched:
                print(f"Warning: Sign '{class_dir.name}' not in TSL_SIGNS list, skipping")
                continue
        
        class_idx = sign_to_index[sign_name]
        class_names.append(sign_name)
        
        # Find all image files
        image_extensions = ['.jpg', '.jpeg', '.png', '.bmp', '.JPG', '.JPEG', '.PNG']
        image_files = []
        for ext in image_extensions:
            image_files.extend(list(class_dir.glob(f'*{ext}')))
            image_files.extend(list(class_dir.glob(f'**/*{ext}')))
        
        if not image_files:
            print(f"Warning: No images found in {class_dir}")
            continue
        
        if max_samples_per_class:
            image_files = image_files[:max_samples_per_class]
        
        print(f"Processing {len(image_files)} images for '{sign_name}' ({class_dir.name})...")
        
        extracted_count = 0
        for img_path in image_files:
            features = extract_landmarks_from_image(img_path, hand_landmarker)
            if features is not None:
                features_list.append(features)
                labels_list.append(class_idx)
                extracted_count += 1
        
        print(f"  ✓ Extracted landmarks from {extracted_count}/{len(image_files)} images")
    
    hand_landmarker.close()
    
    if len(features_list) == 0:
        raise ValueError("No landmarks extracted from dataset!")
    
    X = np.array(features_list)
    y = np.array(labels_list)
    
    print(f"\n{'='*60}")
    print(f"Dataset Summary:")
    print(f"  Total samples: {len(X)}")
    print(f"  Feature shape: {X.shape}")
    print(f"  Number of classes: {len(set(labels_list))}")
    print(f"  Label distribution:")
    unique, counts = np.unique(y, return_counts=True)
    for idx, count in zip(unique, counts):
        if idx < len(TSL_SIGNS):
            print(f"    {TSL_SIGNS[idx]}: {count}")
    print(f"{'='*60}")
    
    return X, y, class_names


def augment_data(X: np.ndarray, y: np.ndarray, augment_factor: int = 2) -> Tuple[np.ndarray, np.ndarray]:
    """Augment landmark data with noise and transformations."""
    augmented_X = [X]
    augmented_y = [y]
    
    for _ in range(augment_factor):
        # Add small random noise
        noise = np.random.normal(0, 0.01, X.shape).astype(np.float32)
        X_noisy = X + noise
        
        # Slight scaling variations
        scale = np.random.uniform(0.95, 1.05, (X.shape[0], 1))
        X_scaled = X * scale
        
        augmented_X.append(X_noisy)
        augmented_X.append(X_scaled)
        augmented_y.append(y)
        augmented_y.append(y)
    
    return np.vstack(augmented_X), np.hstack(augmented_y)


def build_model(input_dim: int, num_classes: int) -> tf.keras.Model:
    """Build a lightweight dense neural network for TSL landmark classification."""
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
        optimizer=tf.keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy', 'top_3_accuracy']
    )
    
    return model


def plot_history(history: tf.keras.callbacks.History, out_dir: Path) -> None:
    """Plot training history."""
    out_dir.mkdir(parents=True, exist_ok=True)
    hist = history.history
    
    # Accuracy
    plt.figure(figsize=(10, 6))
    plt.plot(hist['accuracy'], label='train_acc')
    plt.plot(hist['val_accuracy'], label='val_acc')
    if 'top_3_accuracy' in hist:
        plt.plot(hist['top_3_accuracy'], label='train_top3_acc', linestyle='--')
    plt.legend()
    plt.title('TSL Model - Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.tight_layout()
    plt.savefig(out_dir / 'tsl_model_accuracy.png', dpi=150)
    plt.close()
    
    # Loss
    plt.figure(figsize=(10, 6))
    plt.plot(hist['loss'], label='train_loss')
    plt.plot(hist['val_loss'], label='val_loss')
    plt.legend()
    plt.title('TSL Model - Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.tight_layout()
    plt.savefig(out_dir / 'tsl_model_loss.png', dpi=150)
    plt.close()


def evaluate_model(model: tf.keras.Model, X_test: np.ndarray, y_test: np.ndarray, 
                   class_names: List[str], out_dir: Path) -> None:
    """Evaluate model and save metrics."""
    out_dir.mkdir(parents=True, exist_ok=True)
    
    # Evaluate
    test_loss, test_acc, test_top3 = model.evaluate(X_test, y_test, verbose=0)
    print(f"\n{'='*60}")
    print(f"Test Results:")
    print(f"  Accuracy: {test_acc:.4f}")
    print(f"  Top-3 Accuracy: {test_top3:.4f}")
    print(f"  Loss: {test_loss:.4f}")
    print(f"{'='*60}")
    
    # Predictions
    y_pred_proba = model.predict(X_test, verbose=0)
    y_pred = np.argmax(y_pred_proba, axis=1)
    
    # Classification report
    target_names = [TSL_SIGNS[i] if i < len(TSL_SIGNS) else f"class_{i}" for i in range(len(set(y_test)))]
    report = classification_report(y_test, y_pred, target_names=target_names, output_dict=True)
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=target_names))
    
    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    
    # Save metrics
    metrics = {
        'test_accuracy': float(test_acc),
        'test_top3_accuracy': float(test_top3),
        'test_loss': float(test_loss),
        'num_classes': NUM_CLASSES,
        'classification_report': report,
        'confusion_matrix': cm.tolist()
    }
    
    with open(out_dir / 'tsl_model_metrics.json', 'w') as f:
        json.dump(metrics, f, indent=2)
    
    np.save(out_dir / 'tsl_model_confusion_matrix.npy', cm)


def main():
    """Main training pipeline."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("Tunisian Sign Language (TSL) Model Training")
    print("=" * 60)
    print(f"Target: {NUM_CLASSES} TSL signs")
    print(f"Input: {LANDMARK_DIM} features (21 landmarks × 2)")
    print("=" * 60)
    
    # Step 1: Extract landmarks
    print("\n[1/5] Extracting landmarks from TSL dataset...")
    try:
        X, y, class_names = extract_landmarks_from_dataset(DATASET_DIR, max_samples_per_class=200)
    except Exception as e:
        print(f"Error: {e}")
        print("\nTrying with synthetic data for testing...")
        # Generate synthetic data for testing
        n_samples = 2000
        X = np.random.randn(n_samples, LANDMARK_DIM).astype(np.float32)
        y = np.random.randint(0, min(NUM_CLASSES, 10), size=n_samples)  # Limit to 10 for testing
        class_names = TSL_SIGNS[:min(NUM_CLASSES, 10)]
        print(f"Generated {n_samples} synthetic samples for testing")
    
    # Step 2: Data augmentation
    print("\n[2/5] Augmenting dataset...")
    X_aug, y_aug = augment_data(X, y, augment_factor=1)
    print(f"Augmented dataset: {len(X_aug)} samples (from {len(X)})")
    
    # Step 3: Split data
    print("\n[3/5] Splitting dataset...")
    X_train, X_temp, y_train, y_temp = train_test_split(
        X_aug, y_aug, test_size=(VALIDATION_SPLIT + TEST_SPLIT), random_state=42, stratify=y_aug
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=TEST_SPLIT / (VALIDATION_SPLIT + TEST_SPLIT), 
        random_state=42, stratify=y_temp
    )
    
    print(f"Train: {len(X_train)}, Val: {len(X_val)}, Test: {len(X_test)}")
    
    # Step 4: Build and train model
    print("\n[4/5] Building and training model...")
    model = build_model(LANDMARK_DIM, NUM_CLASSES)
    model.summary()
    
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=20,
            restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=8,
            min_lr=1e-6,
            verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(OUTPUT_DIR / 'tsl_model.h5'),
            monitor='val_loss',
            save_best_only=True,
            verbose=1
        )
    ]
    
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=EPOCHS,
        batch_size=BATCH_SIZE,
        callbacks=callbacks,
        verbose=1
    )
    
    # Load best weights
    model.load_weights(OUTPUT_DIR / 'tsl_model.h5')
    
    # Plot history
    plot_history(history, OUTPUT_DIR)
    
    # Step 5: Evaluate
    print("\n[5/5] Evaluating model...")
    evaluate_model(model, X_test, y_test, class_names, OUTPUT_DIR)
    
    # Save class names
    with open(OUTPUT_DIR / 'tsl_model_classes.json', 'w') as f:
        json.dump(TSL_SIGNS, f, indent=2)
    
    print("\n" + "=" * 60)
    print("Training complete!")
    print(f"Model saved to: {OUTPUT_DIR / 'tsl_model.h5'}")
    print("=" * 60)


if __name__ == "__main__":
    main()

