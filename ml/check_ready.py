"""
Check if system is ready for training.
"""

import sys
from pathlib import Path

def check_python():
    """Check Python version."""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8+ required. Current:", sys.version)
        return False
    print(f"✓ Python {version.major}.{version.minor}.{version.micro}")
    return True

def check_dependencies():
    """Check required packages."""
    required = {
        'tensorflow': 'TensorFlow',
        'mediapipe': 'MediaPipe',
        'cv2': 'OpenCV',
        'numpy': 'NumPy',
        'sklearn': 'scikit-learn',
        'matplotlib': 'Matplotlib'
    }
    
    missing = []
    for module, name in required.items():
        try:
            __import__(module)
            print(f"✓ {name}")
        except ImportError:
            print(f"❌ {name} not installed")
            missing.append(name)
    
    return len(missing) == 0

def check_dataset():
    """Check if dataset is available."""
    tsl_dir = Path("../dataset/tsl_dataset/organized")
    asl_dir = Path("../dataset/asl_alphabet_kaggle")
    
    if tsl_dir.exists() and any(tsl_dir.iterdir()):
        # Count images
        total = sum(1 for _ in tsl_dir.rglob('*.jpg')) + sum(1 for _ in tsl_dir.rglob('*.png'))
        print(f"✓ TSL dataset found ({total} images)")
        return True, 'tsl'
    elif asl_dir.exists():
        print("⚠ TSL dataset not found, but ASL dataset available (can use for testing)")
        return True, 'asl'
    else:
        print("⚠ No dataset found (will use synthetic data for testing)")
        return False, 'synthetic'

def check_output_dir():
    """Check if output directory exists."""
    output_dir = Path("../models")
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"✓ Output directory ready: {output_dir}")
    return True

def main():
    """Run all checks."""
    print("="*60)
    print("TSL Model Training - System Check")
    print("="*60)
    print()
    
    all_ready = True
    
    print("Python Version:")
    if not check_python():
        all_ready = False
    print()
    
    print("Dependencies:")
    if not check_dependencies():
        print("\n⚠ Install missing dependencies:")
        print("  pip3 install -r requirements.txt")
        all_ready = False
    print()
    
    print("Dataset:")
    dataset_ready, dataset_type = check_dataset()
    if not dataset_ready and dataset_type == 'tsl':
        print("\n⚠ Download TSL dataset from:")
        print("  https://data.mendeley.com/datasets/fbjjgzgv7f")
    print()
    
    print("Output Directory:")
    check_output_dir()
    print()
    
    print("="*60)
    if all_ready:
        print("✓ System ready for training!")
        print("\nRun: python3 train_tsl_enhanced.py")
    else:
        print("⚠ System not fully ready")
        print("\nFix issues above, then run training")
    print("="*60)

if __name__ == "__main__":
    main()

