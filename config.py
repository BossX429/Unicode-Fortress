#!/usr/bin/env python3
"""
Unicode-Fortress Configuration
Environment-based configuration for portable deployment
"""

import os
from pathlib import Path

# Base directories - use environment variables with fallbacks
UNICODE_FORTRESS_HOME = Path(os.getenv(
    'UNICODE_FORTRESS_HOME',
    r'C:\repos\Unicode-Fortress'
))

USER_HOME = Path(os.getenv('USERPROFILE', os.path.expanduser('~')))

# Watched directories for Guardian
WATCH_DIRS = [
    Path(os.getenv('WATCH_DIR_1', r'C:\Projects')),
    Path(os.getenv('WATCH_DIR_2', r'C:\repos'))
]

# File extensions to monitor
WATCH_EXTENSIONS = ['.py', '.ps1', '.bat', '.json', '.md', '.txt', '.js', '.ts']

# Guardian configuration
SCAN_INTERVAL = int(os.getenv('UNICODE_SCAN_INTERVAL', '30'))  # seconds
MAX_FILE_SIZE = int(os.getenv('UNICODE_MAX_FILE_SIZE', str(10 * 1024 * 1024)))  # 10MB

# Paths
LOG_FILE = USER_HOME / "unicode_guardian.log"
QUARANTINE_DIR = USER_HOME / "unicode_quarantine"

# Ensure critical directories exist
def ensure_directories():
    """Create necessary directories if they don't exist."""
    QUARANTINE_DIR.mkdir(parents=True, exist_ok=True)

# Display configuration (for debugging)
def show_config():
    """Print current configuration."""
    print("Unicode-Fortress Configuration")
    print("=" * 60)
    print(f"Home:           {UNICODE_FORTRESS_HOME}")
    print(f"User Home:      {USER_HOME}")
    print(f"Log File:       {LOG_FILE}")
    print(f"Quarantine:     {QUARANTINE_DIR}")
    print("=" * 60)
    print("Watched Directories:")
    for watch_dir in WATCH_DIRS:
        exists = "" if watch_dir.exists() else ""
        print(f"  {exists} {watch_dir}")
    print("=" * 60)
    print(f"Scan Interval:  {SCAN_INTERVAL}s")
    print(f"Max File Size:  {MAX_FILE_SIZE:,} bytes ({MAX_FILE_SIZE / (1024*1024):.1f} MB)")
    print(f"Extensions:     {', '.join(WATCH_EXTENSIONS)}")
    print("=" * 60)

if __name__ == "__main__":
    show_config()
    ensure_directories()
    print("\nDirectories verified/created successfully!")
