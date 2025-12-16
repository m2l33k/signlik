import json
import os
from collections import defaultdict
from pathlib import Path

DATASET_DIR = Path("./dataset/asl_alphabet_kaggle")


def analyze_dataset(root: Path) -> dict:
    class_to_count: dict[str, int] = {}
    if not root.exists():
        raise FileNotFoundError(f"Dataset directory not found: {root}")
    for entry in sorted(root.iterdir()):
        if entry.is_dir():
            count = sum(1 for _ in entry.glob("*.*"))
            class_to_count[entry.name] = count
    return class_to_count


def main() -> None:
    class_counts = analyze_dataset(DATASET_DIR)
    total = sum(class_counts.values())
    print(f"Found {len(class_counts)} classes, {total} images total.")
    for cls, cnt in sorted(class_counts.items()):
        print(f"{cls}: {cnt}")
    out_dir = Path("models")
    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "dataset_stats.json", "w", encoding="utf-8") as f:
        json.dump({"class_counts": class_counts, "total": total}, f, indent=2)


if __name__ == "__main__":
    main()



