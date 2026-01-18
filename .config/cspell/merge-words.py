#!/usr/bin/env python3
"""Merge words from system and repo cspell.txt files, sort, and trim whitespace."""

import shutil
from pathlib import Path


def read_words(filepath: Path) -> set[str]:
    """Read words from a file, trimming whitespace and filtering empty lines."""
    words = set()
    if filepath.exists():
        with open(filepath, "r", encoding="utf-8") as f:
            for line in f:
                word = line.rstrip()
                if word:  # Skip empty lines
                    words.add(word)
    return words


def main():
    """Merge words from both cspell.txt files and write sorted result."""
    # Get paths
    home = Path.home()
    system_file = home / ".config" / "cspell" / "cspell.txt"
    repo_file = Path(__file__).parent / "cspell.txt"

    # Read words from both files
    system_words = read_words(system_file)
    repo_words = read_words(repo_file)

    # Merge and sort
    merged_words = sorted(system_words | repo_words)

    # Write back to repo file
    with open(repo_file, "w", encoding="utf-8") as f:
        for word in merged_words:
            f.write(f"{word}\n")

    print(f"Merged {len(system_words)} system words and {len(repo_words)} repo words")
    print(f"Total unique words: {len(merged_words)}")
    print(f"Written to: {repo_file}")

    # Prompt to copy to home folder
    response = input(f"\nCopy merged file to {system_file}? [y/N]: ").strip().lower()
    if response in ("y", "yes"):
        # Ensure the directory exists
        system_file.parent.mkdir(parents=True, exist_ok=True)
        # Copy the file
        shutil.copy2(repo_file, system_file)
        print(f"Copied to: {system_file}")
    else:
        print("Skipped copying to home folder.")


if __name__ == "__main__":
    main()
