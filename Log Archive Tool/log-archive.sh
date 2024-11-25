#!/bin/bash

# Log Archiving Tool
# Compress logs from the specified directory into a .tar.gz file.

# Function to display usage information
usage() {
    echo "Usage: $0 <log-directory>"
    exit 1
}

# Check if a directory argument is provided
if [ $# -ne 1 ]; then
    usage
fi

LOG_DIR=$1

# Check if the provided directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

# Create an archive directory
ARCHIVE_DIR="./archives"
mkdir -p "$ARCHIVE_DIR"

# Generate a timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create a tar.gz archive
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$LOG_DIR" .

# Log the archive creation time
LOG_FILE="$ARCHIVE_DIR/archive_log.txt"
echo "Archived: $ARCHIVE_NAME at $(date)" >> "$LOG_FILE"

# Provide feedback to the user
echo "Logs have been archived to: $ARCHIVE_DIR/$ARCHIVE_NAME"
echo "Archive log updated: $LOG_FILE"
