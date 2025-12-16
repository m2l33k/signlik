"""
Smart dataset organization script for TSL dataset.
Attempts to automatically organize images based on folder names, file names, or patterns.
"""

import shutil
from pathlib import Path
import re
from collections import defaultdict
from typing import Optional

DATASET_DIR = Path("../dataset/tsl_dataset")
ORGANIZED_DIR = Path("../dataset/tsl_dataset/organized")

# TSL sign labels (57 standard signs)
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

# Common variations and mappings
SIGN_VARIATIONS = {
    "hello": ["hello", "hi", "greeting", "salut"],
    "goodbye": ["goodbye", "bye", "farewell", "au revoir"],
    "thank_you": ["thank_you", "thanks", "thank", "merci"],
    "please": ["please", "pls"],
    "sorry": ["sorry", "apology"],
    "yes": ["yes", "oui", "yeah", "yep"],
    "no": ["no", "non", "nope"],
    "maybe": ["maybe", "perhaps"],
    "ok": ["ok", "okay", "fine"],
    "help": ["help", "aid", "assistance"],
    "mother": ["mother", "mom", "mum", "mama"],
    "father": ["father", "dad", "papa"],
    "brother": ["brother", "bro"],
    "sister": ["sister", "sis"],
    "family": ["family", "famille"],
    "water": ["water", "eau"],
    "food": ["food", "nourriture"],
    "eat": ["eat", "eating", "manger"],
    "drink": ["drink", "drinking", "boire"],
    "sleep": ["sleep", "sleeping", "dormir"],
    "house": ["house", "home", "maison"],
    "school": ["school", "ecole"],
    "work": ["work", "travail"],
    "home": ["home", "maison"],
    "friend": ["friend", "ami", "amie"],
    "today": ["today", "aujourd'hui"],
    "tomorrow": ["tomorrow", "demain"],
    "yesterday": ["yesterday", "hier"],
    "morning": ["morning", "matin"],
    "evening": ["evening", "soir"],
    "what": ["what", "quoi"],
    "where": ["where", "ou"],
    "when": ["when", "quand"],
    "why": ["why", "pourquoi"],
    "how": ["how", "comment"],
    "who": ["who", "qui"],
    "go": ["go", "aller"],
    "come": ["come", "venir"],
    "see": ["see", "voir"],
    "hear": ["hear", "entendre"],
    "speak": ["speak", "parler"],
    "read": ["read", "lire"],
    "write": ["write", "ecrire"],
    "learn": ["learn", "apprendre"],
    "teach": ["teach", "enseigner"],
    "understand": ["understand", "comprendre"],
    "zero": ["zero", "0"],
    "one": ["one", "1", "un"],
    "two": ["two", "2", "deux"],
    "three": ["three", "3", "trois"],
    "four": ["four", "4", "quatre"],
    "five": ["five", "5", "cinq"],
    "six": ["six", "6"],
    "seven": ["seven", "7"],
    "eight": ["eight", "8"],
    "nine": ["nine", "9"],
    "good": ["good", "bon", "bien"],
    "bad": ["bad", "mauvais"],
    "happy": ["happy", "heureux"],
    "sad": ["sad", "triste"],
    "love": ["love", "aimer"],
    "like": ["like", "aimer"],
    "want": ["want", "vouloir"],
    "need": ["need", "besoin"]
}


def normalize_name(name: str) -> str:
    """Normalize folder/file name for matching."""
    name = name.lower().strip()
    # Remove special characters, keep alphanumeric and underscore
    name = re.sub(r'[^a-z0-9_]', '_', name)
    # Remove multiple underscores
    name = re.sub(r'_+', '_', name)
    return name.strip('_')


def find_matching_sign(folder_name: str) -> Optional[str]:
    """Find matching TSL sign for a folder name."""
    normalized = normalize_name(folder_name)
    
    # Direct match
    if normalized in TSL_SIGNS:
        return normalized
    
    # Check variations
    for sign, variations in SIGN_VARIATIONS.items():
        if normalized in variations or any(v in normalized for v in variations):
            return sign
        # Check if folder name contains sign name
        if sign in normalized or normalized in sign:
            return sign
    
    # Fuzzy matching - check if any sign is contained in folder name
    for sign in TSL_SIGNS:
        if sign in normalized or normalized in sign:
            return sign
    
    return None


def analyze_dataset_structure(source_dir: Path) -> dict:
    """Analyze the structure of the downloaded dataset."""
    structure = {
        'folders': [],
        'images': [],
        'total_images': 0,
        'organization_type': None
    }
    
    if not source_dir.exists():
        return structure
    
    # Check if images are in subdirectories (class-based)
    subdirs = [d for d in source_dir.iterdir() if d.is_dir() and not d.name.startswith('.')]
    
    if subdirs:
        structure['organization_type'] = 'class_folders'
        for subdir in subdirs:
            images = list(subdir.glob('*.jpg')) + list(subdir.glob('*.png')) + \
                     list(subdir.glob('*.JPG')) + list(subdir.glob('*.PNG'))
            structure['folders'].append({
                'name': subdir.name,
                'path': subdir,
                'image_count': len(images)
            })
            structure['total_images'] += len(images)
    else:
        # Check if images are directly in root
        images = list(source_dir.glob('*.jpg')) + list(source_dir.glob('*.png')) + \
                 list(source_dir.glob('*.JPG')) + list(source_dir.glob('*.PNG'))
        if images:
            structure['organization_type'] = 'flat'
            structure['images'] = images
            structure['total_images'] = len(images)
    
    return structure


def organize_dataset_smart(source_dir: Path, output_dir: Path) -> dict:
    """Smartly organize dataset with automatic matching."""
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Create all sign directories
    for sign in TSL_SIGNS:
        (output_dir / sign).mkdir(exist_ok=True)
    
    # Analyze source structure
    print("Analyzing dataset structure...")
    structure = analyze_dataset_structure(source_dir)
    
    if structure['organization_type'] == 'class_folders':
        print(f"Found {len(structure['folders'])} folders with {structure['total_images']} total images")
        return organize_from_folders(structure['folders'], output_dir)
    elif structure['organization_type'] == 'flat':
        print(f"Found {len(structure['images'])} images in root directory")
        return organize_from_flat(structure['images'], output_dir)
    else:
        print("No images found. Please check dataset location.")
        return {'organized': 0, 'unmapped': 0, 'unmapped_folders': []}


def organize_from_folders(folders: list, output_dir: Path) -> dict:
    """Organize images from class folders."""
    stats = {
        'organized': 0,
        'unmapped': 0,
        'unmapped_folders': [],
        'mapping': {}
    }
    
    for folder_info in folders:
        folder_name = folder_info['name']
        folder_path = folder_info['path']
        image_count = folder_info['image_count']
        
        # Find matching sign
        matched_sign = find_matching_sign(folder_name)
        
        if matched_sign:
            target_dir = output_dir / matched_sign
            stats['mapping'][folder_name] = matched_sign
            
            # Copy images
            images = list(folder_path.glob('*.jpg')) + list(folder_path.glob('*.png')) + \
                     list(folder_path.glob('*.JPG')) + list(folder_path.glob('*.PNG'))
            
            for img in images:
                try:
                    shutil.copy2(img, target_dir / img.name)
                    stats['organized'] += 1
                except Exception as e:
                    print(f"Error copying {img}: {e}")
            
            print(f"✓ Mapped '{folder_name}' → '{matched_sign}' ({image_count} images)")
        else:
            stats['unmapped'] += image_count
            stats['unmapped_folders'].append({
                'name': folder_name,
                'path': folder_path,
                'count': image_count
            })
            print(f"⚠ Could not map '{folder_name}' ({image_count} images) - needs manual organization")
    
    return stats


def organize_from_flat(images: list, output_dir: Path) -> dict:
    """Organize images from flat structure (try to infer from filenames)."""
    stats = {
        'organized': 0,
        'unmapped': 0,
        'unmapped_images': []
    }
    
    for img in images:
        # Try to extract sign name from filename
        # Common patterns: sign_name_001.jpg, hello_1.jpg, etc.
        filename = img.stem.lower()
        
        matched_sign = None
        for sign in TSL_SIGNS:
            if sign in filename:
                matched_sign = sign
                break
        
        if matched_sign:
            target_dir = output_dir / matched_sign
            try:
                shutil.copy2(img, target_dir / img.name)
                stats['organized'] += 1
            except Exception as e:
                print(f"Error copying {img}: {e}")
        else:
            stats['unmapped'] += 1
            stats['unmapped_images'].append(img)
    
    return stats


def generate_organization_report(stats: dict, output_dir: Path) -> None:
    """Generate a report of organization results."""
    report_path = output_dir.parent / "organization_report.txt"
    
    with open(report_path, 'w') as f:
        f.write("TSL Dataset Organization Report\n")
        f.write("=" * 60 + "\n\n")
        f.write(f"Total images organized: {stats['organized']}\n")
        f.write(f"Unmapped images: {stats['unmapped']}\n\n")
        
        if 'mapping' in stats and stats['mapping']:
            f.write("Folder Mappings:\n")
            for folder, sign in stats['mapping'].items():
                f.write(f"  {folder} → {sign}\n")
            f.write("\n")
        
        if 'unmapped_folders' in stats and stats['unmapped_folders']:
            f.write("Folders needing manual organization:\n")
            for folder in stats['unmapped_folders']:
                f.write(f"  {folder['name']} ({folder['count']} images) at {folder['path']}\n")
            f.write("\n")
        
        # Count images per sign
        f.write("Images per sign:\n")
        for sign in TSL_SIGNS:
            sign_dir = output_dir / sign
            if sign_dir.exists():
                count = len(list(sign_dir.glob('*.jpg')) + list(sign_dir.glob('*.png')))
                f.write(f"  {sign}: {count} images\n")
    
    print(f"\nOrganization report saved to: {report_path}")


def main():
    """Main organization function."""
    print("=" * 60)
    print("Smart TSL Dataset Organization")
    print("=" * 60)
    
    # Check if source dataset exists
    if not DATASET_DIR.exists():
        print(f"\nDataset directory not found: {DATASET_DIR}")
        print("Please download the dataset first:")
        print("1. Visit: https://data.mendeley.com/datasets/fbjjgzgv7f")
        print("2. Download and extract to:", DATASET_DIR)
        return
    
    # Try to find dataset in various locations
    possible_locations = [
        DATASET_DIR,
        DATASET_DIR / "raw",
        DATASET_DIR / "extracted",
        Path("../dataset/tsl_dataset"),
    ]
    
    source_dir = None
    for loc in possible_locations:
        if loc.exists() and any(loc.iterdir()):
            source_dir = loc
            break
    
    if not source_dir:
        print(f"\nCould not find dataset files in: {DATASET_DIR}")
        print("Please ensure dataset is downloaded and extracted.")
        return
    
    print(f"\nSource dataset found at: {source_dir}")
    
    # Organize dataset
    print("\nOrganizing dataset...")
    stats = organize_dataset_smart(source_dir, ORGANIZED_DIR)
    
    # Generate report
    generate_organization_report(stats, ORGANIZED_DIR)
    
    # Summary
    print("\n" + "=" * 60)
    print("Organization Summary")
    print("=" * 60)
    print(f"✓ Organized: {stats['organized']} images")
    print(f"⚠ Unmapped: {stats['unmapped']} images (may need manual organization)")
    
    if stats['organized'] > 0:
        print(f"\n✓ Dataset ready for training!")
        print(f"Location: {ORGANIZED_DIR}")
    else:
        print(f"\n⚠ No images were automatically organized.")
        print("You may need to manually organize the dataset.")
    
    print("=" * 60)


if __name__ == "__main__":
    main()

