"""
Enhanced TSL model training with best practices:
- Advanced data augmentation
- Optimal hyperparameters
- Comprehensive evaluation
- Model checkpointing
"""

import json
import numpy as np
import tensorflow as tf
from pathlib import Path
from typing import List, Tuple, Optional
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
import cv2
import mediapipe as mp

DATASET_DIR = Path("../dataset/tsl_dataset/organized")
OUTPUT_DIR = Path("../models")
NUM_CLASSES = 57
LANDMARK_DIM = 42
EPOCHS = 200  # Increased for better convergence
BATCH_SIZE = 32
LEARNING_RATE = 1e-3
VALIDATION_SPLIT = 0.15
TEST_SPLIT = 0.15

# TSL sign labels
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
    
    # Normalize relative to wrist
    wrist = points[0]
    normalized = points - wrist
    
    return normalized.flatten().astype(np.float32)


def extract_landmarks_from_dataset(data_dir: Path, max_samples_per_class: int = None) -> Tuple[np.ndarray, np.ndarray, List[str]]:
    """Extract landmarks from all images in the TSL dataset."""
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
    
    class_dirs = sorted([d for d in data_dir.iterdir() if d.is_dir() and not d.name.startswith('.')])
    
    if not class_dirs:
        raise ValueError(f"No class directories found in {data_dir}")
    
    sign_to_index = {sign: idx for idx, sign in enumerate(TSL_SIGNS)}
    
    print(f"Found {len(class_dirs)} sign directories")
    
    for class_dir in class_dirs:
        sign_name = normalize_sign_name(class_dir.name)
        
        if sign_name not in sign_to_index:
            print(f"⚠ Skipping '{class_dir.name}' (not in TSL_SIGNS)")
            continue
        
        class_idx = sign_to_index[sign_name]
        class_names.append(sign_name)
        
        image_files = list(class_dir.glob('*.jpg')) + list(class_dir.glob('*.png')) + \
                      list(class_dir.glob('*.JPG')) + list(class_dir.glob('*.PNG'))
        
        if not image_files:
            print(f"⚠ No images in {class_dir.name}")
            continue
        
        if max_samples_per_class:
            image_files = image_files[:max_samples_per_class]
        
        print(f"Processing {len(image_files)} images for '{sign_name}'...")
        
        extracted = 0
        for img_path in image_files:
            features = extract_landmarks_from_image(img_path, hand_landmarker)
            if features is not None:
                features_list.append(features)
                labels_list.append(class_idx)
                extracted += 1
        
        print(f"  ✓ Extracted {extracted}/{len(image_files)} landmarks")
    
    hand_landmarker.close()
    
    if len(features_list) == 0:
        raise ValueError("No landmarks extracted!")
    
    X = np.array(features_list)
    y = np.array(labels_list)
    
    print(f"\n{'='*60}")
    print(f"Dataset Summary:")
    print(f"  Total samples: {len(X)}")
    print(f"  Classes: {len(set(labels_list))}")
    print(f"{'='*60}")
    
    return X, y, class_names


def normalize_sign_name(name: str) -> str:
    """Normalize sign name for matching."""
    name = name.lower().strip().replace(' ', '_').replace('-', '_')
    # Direct match
    if name in TSL_SIGNS:
        return name
    # Try variations
    for sign in TSL_SIGNS:
        if sign in name or name in sign:
            return sign
    return name


def augment_data_advanced(X: np.ndarray, y: np.ndarray, augment_factor: int = 3) -> Tuple[np.ndarray, np.ndarray]:
    """Advanced data augmentation with multiple techniques."""
    augmented_X = [X]
    augmented_y = [y]
    
    print(f"Augmenting dataset (factor: {augment_factor}x)...")
    
    for i in range(augment_factor):
        # 1. Gaussian noise (multiple levels)
        noise_levels = [0.005, 0.01, 0.015]
        for noise_std in noise_levels:
            noise = np.random.normal(0, noise_std, X.shape).astype(np.float32)
            X_noisy = X + noise
            augmented_X.append(X_noisy)
            augmented_y.append(y)
        
        # 2. Scaling variations
        scales = [0.95, 0.97, 1.03, 1.05]
        for scale in scales:
            X_scaled = X * scale
            augmented_X.append(X_scaled)
            augmented_y.append(y)
        
        # 3. Combined noise + scale
        for scale in [0.98, 1.02]:
            noise = np.random.normal(0, 0.008, X.shape).astype(np.float32)
            X_combined = X * scale + noise
            augmented_X.append(X_combined)
            augmented_y.append(y)
    
    X_aug = np.vstack(augmented_X)
    y_aug = np.hstack(augmented_y)
    
    print(f"  Original: {len(X)} samples")
    print(f"  Augmented: {len(X_aug)} samples ({len(X_aug)/len(X):.1f}x)")
    
    return X_aug, y_aug


def build_enhanced_model(input_dim: int, num_classes: int) -> tf.keras.Model:
    """Build enhanced model with best practices."""
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(input_dim,)),
        
        # First block
        tf.keras.layers.Dense(256, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.4),
        
        # Second block
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        
        # Third block
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),
        
        # Output
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    
    # Use Adam optimizer with weight decay
    optimizer = tf.keras.optimizers.Adam(
        learning_rate=LEARNING_RATE,
        beta_1=0.9,
        beta_2=0.999,
        epsilon=1e-7
    )
    
    model.compile(
        optimizer=optimizer,
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy', 'top_3_accuracy', 'top_5_accuracy']
    )
    
    return model


def plot_training_history(history: tf.keras.callbacks.History, out_dir: Path) -> None:
    """Plot comprehensive training history."""
    out_dir.mkdir(parents=True, exist_ok=True)
    hist = history.history
    
    # Accuracy plot
    plt.figure(figsize=(12, 5))
    plt.subplot(1, 2, 1)
    plt.plot(hist['accuracy'], label='Train', linewidth=2)
    plt.plot(hist['val_accuracy'], label='Validation', linewidth=2)
    if 'top_3_accuracy' in hist:
        plt.plot(hist['top_3_accuracy'], label='Train Top-3', linestyle='--', alpha=0.7)
    plt.xlabel('Epoch', fontsize=12)
    plt.ylabel('Accuracy', fontsize=12)
    plt.title('Model Accuracy', fontsize=14, fontweight='bold')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    # Loss plot
    plt.subplot(1, 2, 2)
    plt.plot(hist['loss'], label='Train', linewidth=2)
    plt.plot(hist['val_loss'], label='Validation', linewidth=2)
    plt.xlabel('Epoch', fontsize=12)
    plt.ylabel('Loss', fontsize=12)
    plt.title('Model Loss', fontsize=14, fontweight='bold')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(out_dir / 'tsl_training_history.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print(f"✓ Training plots saved to: {out_dir / 'tsl_training_history.png'}")


def evaluate_model_comprehensive(model: tf.keras.Model, X_test: np.ndarray, y_test: np.ndarray,
                                 class_names: List[str], out_dir: Path) -> dict:
    """Comprehensive model evaluation."""
    out_dir.mkdir(parents=True, exist_ok=True)
    
    print("\n" + "="*60)
    print("Comprehensive Model Evaluation")
    print("="*60)
    
    # Evaluate
    results = model.evaluate(X_test, y_test, verbose=0)
    test_loss = results[0]
    test_acc = results[1]
    test_top3 = results[2] if len(results) > 2 else 0
    test_top5 = results[3] if len(results) > 3 else 0
    
    print(f"\nTest Metrics:")
    print(f"  Loss: {test_loss:.4f}")
    print(f"  Accuracy: {test_acc:.4f} ({test_acc*100:.2f}%)")
    print(f"  Top-3 Accuracy: {test_top3:.4f} ({test_top3*100:.2f}%)")
    print(f"  Top-5 Accuracy: {test_top5:.4f} ({test_top5*100:.2f}%)")
    
    # Predictions
    y_pred_proba = model.predict(X_test, verbose=0)
    y_pred = np.argmax(y_pred_proba, axis=1)
    
    # Per-class accuracy
    print(f"\nPer-Class Accuracy:")
    class_accuracies = {}
    for i in range(len(TSL_SIGNS)):
        mask = y_test == i
        if np.sum(mask) > 0:
            class_acc = np.mean(y_pred[mask] == y_test[mask])
            class_accuracies[TSL_SIGNS[i]] = class_acc
            if class_acc < 0.7:  # Highlight low accuracy
                print(f"  ⚠ {TSL_SIGNS[i]}: {class_acc:.2%} ({np.sum(mask)} samples)")
            else:
                print(f"  ✓ {TSL_SIGNS[i]}: {class_acc:.2%} ({np.sum(mask)} samples)")
    
    # Classification report
    target_names = [TSL_SIGNS[i] if i < len(TSL_SIGNS) else f"class_{i}" for i in range(len(set(y_test)))]
    report = classification_report(y_test, y_pred, target_names=target_names, output_dict=True)
    
    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    
    # Save metrics
    metrics = {
        'test_accuracy': float(test_acc),
        'test_top3_accuracy': float(test_top3),
        'test_top5_accuracy': float(test_top5),
        'test_loss': float(test_loss),
        'num_classes': NUM_CLASSES,
        'total_samples': len(X_test),
        'class_accuracies': class_accuracies,
        'classification_report': report,
        'confusion_matrix': cm.tolist()
    }
    
    with open(out_dir / 'tsl_model_metrics.json', 'w') as f:
        json.dump(metrics, f, indent=2)
    
    np.save(out_dir / 'tsl_confusion_matrix.npy', cm)
    
    print(f"\n✓ Metrics saved to: {out_dir / 'tsl_model_metrics.json'}")
    
    return metrics


def main():
    """Main training pipeline."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print("="*60)
    print("Enhanced TSL Model Training")
    print("="*60)
    print(f"Target: {NUM_CLASSES} TSL signs")
    print(f"Input: {LANDMARK_DIM} features")
    print("="*60)
    
    # Step 1: Extract landmarks
    print("\n[1/6] Extracting landmarks from TSL dataset...")
    try:
        X, y, class_names = extract_landmarks_from_dataset(DATASET_DIR, max_samples_per_class=300)
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\nTrying with synthetic data for testing...")
        n_samples = 2000
        X = np.random.randn(n_samples, LANDMARK_DIM).astype(np.float32)
        y = np.random.randint(0, min(NUM_CLASSES, 10), size=n_samples)
        class_names = TSL_SIGNS[:min(NUM_CLASSES, 10)]
        print(f"Generated {n_samples} synthetic samples for testing")
    
    # Step 2: Advanced augmentation
    print("\n[2/6] Applying advanced data augmentation...")
    X_aug, y_aug = augment_data_advanced(X, y, augment_factor=3)
    
    # Step 3: Split data
    print("\n[3/6] Splitting dataset...")
    X_train, X_temp, y_train, y_temp = train_test_split(
        X_aug, y_aug, test_size=(VALIDATION_SPLIT + TEST_SPLIT), 
        random_state=42, stratify=y_aug
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=TEST_SPLIT / (VALIDATION_SPLIT + TEST_SPLIT),
        random_state=42, stratify=y_temp
    )
    
    print(f"  Train: {len(X_train)}")
    print(f"  Validation: {len(X_val)}")
    print(f"  Test: {len(X_test)}")
    
    # Step 4: Build model
    print("\n[4/6] Building enhanced model...")
    model = build_enhanced_model(LANDMARK_DIM, NUM_CLASSES)
    model.summary()
    
    # Step 5: Train
    print("\n[5/6] Training model...")
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=25,
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
        ),
        tf.keras.callbacks.CSVLogger(
            str(OUTPUT_DIR / 'training_log.csv')
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
    plot_training_history(history, OUTPUT_DIR)
    
    # Step 6: Evaluate
    print("\n[6/6] Evaluating model...")
    metrics = evaluate_model_comprehensive(model, X_test, y_test, class_names, OUTPUT_DIR)
    
    # Save class labels
    with open(OUTPUT_DIR / 'tsl_model_classes.json', 'w') as f:
        json.dump(TSL_SIGNS, f, indent=2)
    
    print("\n" + "="*60)
    print("Training Complete!")
    print("="*60)
    print(f"✓ Model saved: {OUTPUT_DIR / 'tsl_model.h5'}")
    print(f"✓ Test Accuracy: {metrics['test_accuracy']:.2%}")
    print(f"✓ Top-3 Accuracy: {metrics['test_top3_accuracy']:.2%}")
    print("="*60)


if __name__ == "__main__":
    main()

