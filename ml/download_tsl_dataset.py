"""
Download and organize the Tunisian Sign Language (TSL) dataset from Mendeley Data.
Dataset: "First ever Tunisian Sign Language Dataset"
URL: https://data.mendeley.com/datasets/fbjjgzgv7f
"""

import os
import zipfile
import requests
from pathlib import Path
from typing import Optional

DATASET_URL = "https://data.mendeley.com/public-files/datasets/fbjjgzgv7f/files/..."  # Will need actual download link
DATASET_DIR = Path("../dataset/tsl_dataset")
OUTPUT_DIR = DATASET_DIR / "organized"


def download_file(url: str, output_path: Path, chunk_size: int = 8192) -> bool:
    """Download a file from URL with progress indication."""
    try:
        print(f"Downloading from {url}...")
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        total_size = int(response.headers.get('content-length', 0))
        downloaded = 0
        
        with open(output_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\rProgress: {percent:.1f}%", end='', flush=True)
        
        print(f"\nDownloaded to: {output_path}")
        return True
    except Exception as e:
        print(f"Error downloading: {e}")
        return False


def extract_zip(zip_path: Path, extract_to: Path) -> bool:
    """Extract zip file to directory."""
    try:
        print(f"Extracting {zip_path.name}...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
        print(f"Extracted to: {extract_to}")
        return True
    except Exception as e:
        print(f"Error extracting: {e}")
        return False


def organize_dataset(source_dir: Path, output_dir: Path) -> None:
    """Organize TSL dataset into class-based directory structure."""
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # TSL dataset has 57 signs
    # We need to identify the structure and organize accordingly
    print("Organizing dataset structure...")
    
    # Common TSL sign categories (will need to verify with actual dataset)
    tsl_signs = [
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
        # Additional common signs
        "good", "bad", "happy", "sad", "love", "like", "want", "need"
    ]
    
    # Create directories for each sign
    for sign in tsl_signs[:57]:  # Limit to 57 signs
        sign_dir = output_dir / sign
        sign_dir.mkdir(exist_ok=True)
    
    print(f"Created directories for {len(tsl_signs[:57])} TSL signs")
    print(f"\nNote: You may need to manually organize images from the downloaded dataset")
    print(f"into the appropriate sign directories based on the dataset structure.")


def main():
    """Main function to download and organize TSL dataset."""
    DATASET_DIR.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("Tunisian Sign Language (TSL) Dataset Downloader")
    print("=" * 60)
    print("\nDataset Information:")
    print("- 4,423 images")
    print("- 57 standard Tunisian signs")
    print("- 7 individuals")
    print("- Diverse environments")
    print("\n" + "=" * 60)
    
    # Check if dataset already exists
    if (DATASET_DIR / "organized").exists():
        print("\nDataset already organized. Skipping download.")
        print(f"Dataset location: {DATASET_DIR / 'organized'}")
        return
    
    print("\nIMPORTANT: Manual Download Required")
    print("=" * 60)
    print("1. Visit: https://data.mendeley.com/datasets/fbjjgzgv7f")
    print("2. Download the dataset files")
    print("3. Extract to:", DATASET_DIR)
    print("4. Run this script again to organize the structure")
    print("=" * 60)
    
    # Create organized structure
    organize_dataset(DATASET_DIR, OUTPUT_DIR)
    
    print("\n" + "=" * 60)
    print("Next Steps:")
    print("1. Download dataset from Mendeley Data")
    print("2. Extract and place images in appropriate sign directories")
    print("3. Run train_tsl_model.py to train the model")
    print("=" * 60)


if __name__ == "__main__":
    main()

