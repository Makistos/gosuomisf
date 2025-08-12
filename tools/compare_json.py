import argparse
import json
from deepdiff import DeepDiff


def normalize(obj):
    """Recursively sort dict keys and list elements for order-insensitive comparison."""
    if isinstance(obj, dict):
        return {k: normalize(v) for k, v in sorted(obj.items())}
    elif isinstance(obj, list):
        # Sort list elements after normalization
        return sorted((normalize(v) for v in obj), key=lambda x: json.dumps(x, sort_keys=True))
    else:
        return obj


def main():
    parser = argparse.ArgumentParser(
        description="Compare two JSON files (order-insensitive).")
    parser.add_argument("file1", help="First JSON file")
    parser.add_argument("file2", help="Second JSON file")
    args = parser.parse_args()

    with open(args.file1, 'r', encoding='utf-8') as f1:
        data1 = json.load(f1)
    with open(args.file2, 'r', encoding='utf-8') as f2:
        data2 = json.load(f2)

    norm1 = normalize(data1)
    norm2 = normalize(data2)

    if norm1 == norm2:
        print("✅ Files have the same JSON contents.")
    else:
        print("❌ Files differ.\n")
        diff = DeepDiff(norm1, norm2, ignore_order=True)
        print(diff.pretty())


if __name__ == "__main__":
    main()
