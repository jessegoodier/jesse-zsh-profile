#!/bin/bash

# Script to check for duplicate aliases and functions in shell alias files
# Checks both within individual files and between files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# File paths
ALIASES_LOCAL=".aliases-local"
ALIASES_SH=".aliases"

# Global flag to track if any duplicates were found
DUPLICATES_FOUND=false

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to extract aliases from a file
extract_aliases() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        print_status $RED "Error: File $file not found"
        return 1
    fi
    
    # Extract aliases (lines starting with 'alias ')
    grep -E '^alias [^=]+=' "$file" 2>/dev/null | sed 's/^alias //' | sed 's/=.*$//' || true
}

# Function to extract function names from a file
extract_functions() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        print_status $RED "Error: File $file not found"
        return 1
    fi
    
    # Extract function names (lines matching 'function_name() {')
    grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\(\)' "$file" 2>/dev/null | sed 's/()//' || true
}

# Function to check for duplicates within a single file
check_duplicates_within_file() {
    local file="$1"
    local file_type="$2"
    
    print_status $BLUE "\n=== Checking duplicates within $file_type ==="
    
    # Check for duplicate aliases
    local aliases
    aliases=$(extract_aliases "$file")
    if [[ -n "$aliases" ]]; then
        local duplicate_aliases
        duplicate_aliases=$(echo "$aliases" | sort | uniq -d)
        if [[ -n "$duplicate_aliases" ]]; then
            print_status $RED "❌ Duplicate aliases found in $file:"
            DUPLICATES_FOUND=true
            echo "$duplicate_aliases" | while read -r alias; do
                print_status $YELLOW "  - $alias"
            done
        else
            print_status $GREEN "✅ No duplicate aliases found in $file"
        fi
    fi
    
    # Check for duplicate functions
    local functions
    functions=$(extract_functions "$file")
    if [[ -n "$functions" ]]; then
        local duplicate_functions
        duplicate_functions=$(echo "$functions" | sort | uniq -d)
        if [[ -n "$duplicate_functions" ]]; then
            print_status $RED "❌ Duplicate functions found in $file:"
            DUPLICATES_FOUND=true
            echo "$duplicate_functions" | while read -r func; do
                print_status $YELLOW "  - $func"
            done
        else
            print_status $GREEN "✅ No duplicate functions found in $file"
        fi
    fi
}

# Function to check for duplicates between files
check_duplicates_between_files() {
    print_status $BLUE "\n=== Checking duplicates between files ==="
    
    # Extract all aliases from both files
    local aliases_local aliases_sh
    aliases_local=$(extract_aliases "$ALIASES_LOCAL")
    aliases_sh=$(extract_aliases "$ALIASES_SH")
    
    # Find common aliases
    if [[ -n "$aliases_local" && -n "$aliases_sh" ]]; then
        local common_aliases
        common_aliases=$(comm -12 <(echo "$aliases_local" | sort) <(echo "$aliases_sh" | sort))
        if [[ -n "$common_aliases" ]]; then
            print_status $RED "❌ Aliases found in both files:"
            DUPLICATES_FOUND=true
            echo "$common_aliases" | while read -r alias; do
                print_status $YELLOW "  - $alias"
            done
        else
            print_status $GREEN "✅ No duplicate aliases between files"
        fi
    fi
    
    # Extract all functions from both files
    local functions_local functions_sh
    functions_local=$(extract_functions "$ALIASES_LOCAL")
    functions_sh=$(extract_functions "$ALIASES_SH")
    
    # Find common functions
    if [[ -n "$functions_local" && -n "$functions_sh" ]]; then
        local common_functions
        common_functions=$(comm -12 <(echo "$functions_local" | sort) <(echo "$functions_sh" | sort))
        if [[ -n "$common_functions" ]]; then
            print_status $RED "❌ Functions found in both files:"
            DUPLICATES_FOUND=true
            echo "$common_functions" | while read -r func; do
                print_status $YELLOW "  - $func"
            done
        else
            print_status $GREEN "✅ No duplicate functions between files"
        fi
    fi
}

# Function to show summary of all aliases and functions
show_summary() {
    print_status $BLUE "\n=== Summary of all aliases and functions ==="
    
    print_status $YELLOW "\nAliases in $ALIASES_LOCAL:"
    local aliases_local
    aliases_local=$(extract_aliases "$ALIASES_LOCAL" | sort)
    if [[ -n "$aliases_local" ]]; then
        echo "$aliases_local" | nl
    else
        print_status $YELLOW "  (none found)"
    fi
    
    print_status $YELLOW "\nFunctions in $ALIASES_LOCAL:"
    local functions_local
    functions_local=$(extract_functions "$ALIASES_LOCAL" | sort)
    if [[ -n "$functions_local" ]]; then
        echo "$functions_local" | nl
    else
        print_status $YELLOW "  (none found)"
    fi
    
    print_status $YELLOW "\nAliases in $ALIASES_SH:"
    local aliases_sh
    aliases_sh=$(extract_aliases "$ALIASES_SH" | sort)
    if [[ -n "$aliases_sh" ]]; then
        echo "$aliases_sh" | nl
    else
        print_status $YELLOW "  (none found)"
    fi
    
    print_status $YELLOW "\nFunctions in $ALIASES_SH:"
    local functions_sh
    functions_sh=$(extract_functions "$ALIASES_SH" | sort)
    if [[ -n "$functions_sh" ]]; then
        echo "$functions_sh" | nl
    else
        print_status $YELLOW "  (none found)"
    fi
}

# Function to show final result
show_final_result() {
    print_status $BLUE "\n=== Final Result ==="
    
    if [[ "$DUPLICATES_FOUND" == true ]]; then
        print_status $RED "❌ Duplicates were found! Please review and resolve them."
    else
        print_status $GREEN "🎉 No duplicates found! Your alias files are clean."
    fi
}

# Main execution
main() {
    print_status $BLUE "🔍 Duplicate Checker for Shell Alias Files"
    print_status $BLUE "=========================================="
    
    # Check if files exist
    if [[ ! -f "$ALIASES_LOCAL" ]]; then
        print_status $RED "Error: $ALIASES_LOCAL not found"
        exit 1
    fi
    
    if [[ ! -f "$ALIASES_SH" ]]; then
        print_status $RED "Error: $ALIASES_SH not found"
        exit 1
    fi
    
    # Run all checks
    check_duplicates_within_file "$ALIASES_LOCAL" "$ALIASES_LOCAL"
    check_duplicates_within_file "$ALIASES_SH" "$ALIASES_SH"
    check_duplicates_between_files
    
    # # Show summary
    # show_summary
    
    # Show final result
    show_final_result
    
    print_status $BLUE "\n=== Check complete ==="
}

# Run main function
main "$@"
