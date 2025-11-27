#!/usr/bin/env python3
"""
UNICODE FORTRESS - Layer 2: Real-Time Guardian (FIXED)
Monitors files for ACTUAL Unicode corruption, not valid UTF-8
"""

import os
import sys
import time
from pathlib import Path
from datetime import datetime
import shutil

# Monitoring configuration
WATCH_DIRS = [
    r"C:\Projects",
    r"C:\repos"
]

WATCH_EXTENSIONS = ['.py', '.ps1', '.bat', '.json', '.md', '.txt', '.js', '.ts']
SCAN_INTERVAL = 30  # seconds
LOG_FILE = r"C:\Users\kyleh\unicode_guardian.log"
QUARANTINE_DIR = r"C:\Users\kyleh\unicode_quarantine"

def log(message):
    """Log to file and console"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_message = f"[{timestamp}] {message}"
    print(log_message)
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(log_message + '\n')

def ensure_quarantine_dir():
    """Ensure quarantine directory exists"""
    Path(QUARANTINE_DIR).mkdir(parents=True, exist_ok=True)

def check_file_encoding(filepath):
    """Check if file has REAL UTF-8 encoding issues"""
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # Try to decode as UTF-8 - this is the REAL test
        try:
            decoded = content.decode('utf-8')
            # If we got here, it's valid UTF-8!
            return True, "Valid UTF-8"
        except UnicodeDecodeError as e:
            # This is REAL corruption
            return False, f"Invalid UTF-8: {str(e)}"
    
    except Exception as e:
        return True, f"Cannot check: {str(e)}"


def quarantine_file(filepath):
    """Move corrupted file to quarantine"""
    ensure_quarantine_dir()
    filename = Path(filepath).name
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    quarantine_path = Path(QUARANTINE_DIR) / f"{timestamp}_{filename}"
    
    shutil.copy2(filepath, quarantine_path)
    log(f"    QUARANTINED: {filepath} -> {quarantine_path}")
    return quarantine_path

def fix_file_encoding(filepath):
    """Attempt to fix file encoding"""
    try:
        # Read with error handling
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # Try different encodings in order
        decoded = None
        tried_encodings = ['utf-8', 'latin-1', 'cp1252', 'utf-16']
        
        for encoding in tried_encodings:
            try:
                decoded = content.decode(encoding)
                break
            except (UnicodeDecodeError, LookupError):
                continue
        
        if decoded is None:
            # Last resort: replace errors
            decoded = content.decode('utf-8', errors='replace')
        
        # Write back as clean UTF-8
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(decoded)
        
        log(f"   FIXED: {filepath}")
        return True
    except Exception as e:
        log(f"   FAILED to fix {filepath}: {e}")
        return False


def scan_directory(directory):
    """Scan directory for corrupted files"""
    issues_found = 0
    files_checked = 0
    
    for root, dirs, files in os.walk(directory):
        # Skip certain directories
        dirs[:] = [d for d in dirs if d not in ['node_modules', '.git', '__pycache__', 'venv', 'unicode_quarantine']]
        
        for filename in files:
            if any(filename.endswith(ext) for ext in WATCH_EXTENSIONS):
                filepath = os.path.join(root, filename)
                files_checked += 1
                
                is_clean, reason = check_file_encoding(filepath)
                
                if not is_clean:
                    log(f" REAL CORRUPTION DETECTED: {filepath}")
                    log(f"   Reason: {reason}")
                    
                    # Quarantine then fix
                    quarantine_file(filepath)
                    if fix_file_encoding(filepath):
                        issues_found += 1
    
    return files_checked, issues_found

def main():
    """Main guardian loop"""
    log("=" * 60)
    log("  UNICODE FORTRESS GUARDIAN V2 STARTED (FIXED DETECTION)")
    log("=" * 60)
    log(f"Watching directories: {', '.join(WATCH_DIRS)}")
    log(f"Scan interval: {SCAN_INTERVAL}s")
    log(f"Quarantine: {QUARANTINE_DIR}")
    log("")
    
    ensure_quarantine_dir()
    
    scan_count = 0
    while True:
        try:
            scan_count += 1
            log(f"--- Scan #{scan_count} ---")
            
            total_files = 0
            total_issues = 0
            
            for directory in WATCH_DIRS:
                if os.path.exists(directory):
                    log(f"Scanning: {directory}")
                    files, issues = scan_directory(directory)
                    total_files += files
                    total_issues += issues
            
            if total_issues > 0:
                log(f"  Found and fixed {total_issues} REAL corrupted files out of {total_files} checked")
            else:
                log(f" All {total_files} files are valid UTF-8")
            
            log(f"Next scan in {SCAN_INTERVAL}s...")
            log("")
            time.sleep(SCAN_INTERVAL)
            
        except KeyboardInterrupt:
            log(" Guardian stopped by user")
            break
        except Exception as e:
            log(f" Error in guardian loop: {e}")
            time.sleep(SCAN_INTERVAL)

if __name__ == "__main__":
    main()
