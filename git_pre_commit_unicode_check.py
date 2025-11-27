#!/usr/bin/env python3
"""
UNICODE FORTRESS - Layer 3: Git Pre-Commit Hook
Blocks commits with Unicode corruption
"""

import sys
import subprocess
import re

def check_file_utf8(filepath):
    """Check if file is valid UTF-8"""
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # Check for corruption patterns
        corruption_patterns = [
            rb'\xef\xbf\xbd',  # Replacement character
            rb'[\x80-\x9f]',   # Invalid UTF-8 control
        ]
        
        for pattern in corruption_patterns:
            if re.search(pattern, content):
                return False, "Corruption pattern detected"
        
        # Validate UTF-8
        try:
            content.decode('utf-8')
            return True, "OK"
        except UnicodeDecodeError as e:
            return False, f"Invalid UTF-8: {str(e)}"
    except Exception as e:
        return True, f"Cannot check: {str(e)}"

def main():
    """Check staged files for Unicode issues"""
    # Get staged files
    result = subprocess.run(
        ['git', 'diff', '--cached', '--name-only', '--diff-filter=ACM'],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        return 0  # Not in git repo, allow commit
    
    staged_files = result.stdout.strip().split('\n')
    extensions = ['.py', '.ps1', '.bat', '.json', '.md', '.txt', '.js', '.ts']
    
    corrupted_files = []
    
    for filepath in staged_files:
        if not filepath:
            continue
        
        if any(filepath.endswith(ext) for ext in extensions):
            is_clean, reason = check_file_utf8(filepath)
            if not is_clean:
                corrupted_files.append((filepath, reason))
    
    if corrupted_files:
        print("\n" + "=" * 60)
        print(" UNICODE FORTRESS: COMMIT BLOCKED")
        print("=" * 60)
        print("The following files have Unicode corruption:\n")
        for filepath, reason in corrupted_files:
            print(f"   {filepath}")
            print(f"     Reason: {reason}\n")
        print("Fix these files before committing!")
        print("Run: python C:\\Users\\kyleh\\unicode_guardian.py")
        print("=" * 60)
        return 1  # Block commit
    
    return 0  # Allow commit

if __name__ == "__main__":
    sys.exit(main())
