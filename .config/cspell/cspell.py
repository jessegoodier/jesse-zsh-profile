#!/usr/bin/env python3
import json
from pathlib import Path

def main():
    # Define paths
    # Global config path
    global_config_path = Path.home() / ".config/cspell/cspell.json"
    
    # Local config path (relative to this script)
    local_config_path = Path(__file__).parent / "cspell.json"
    
    # Check if files exist
    if not global_config_path.exists():
        print(f"Global config not found at {global_config_path}")
        return

    if not local_config_path.exists():
        print(f"Local config not found at {local_config_path}")
        return

    # Load global words
    try:
        with open(global_config_path, "r", encoding="utf-8") as f:
            global_data = json.load(f)
            global_words = set(global_data.get("words", []))
    except Exception as e:
        print(f"Error reading global config: {e}")
        return

    # Load local words
    try:
        with open(local_config_path, "r", encoding="utf-8") as f:
            local_data = json.load(f)
            local_words = set(local_data.get("words", []))
    except Exception as e:
        print(f"Error reading local config: {e}")
        return

    # Merge words (local | global)
    # The requirement is: "pull in additions from ~/.config/cspell/cspell.json and merge them in"
    # "never remove entries, only add new"
    merged_words = local_words.union(global_words)
    
    # Sort case-insensitive to keep it clean
    sorted_words = sorted(list(merged_words), key=str.lower)
    
    # Update local data
    local_data["words"] = sorted_words
    
    # Write back
    try:
        with open(local_config_path, "w", encoding="utf-8") as f:
            json.dump(local_data, f, indent=4)
            # Add a trailing newline
            f.write("\n")
        print(f"Successfully merged words. Total count: {len(sorted_words)}")
    except Exception as e:
        print(f"Error writing local config: {e}")

if __name__ == "__main__":
    main()
