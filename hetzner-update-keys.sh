#!/bin/bash
set -e

# Configuration
SSH_REMOTE="hetzner-backup"

# Create temporary file
TEMP_FILE=$(mktemp /tmp/authorized_keys.XXXXXX)

# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

# Download authorized_keys from remote
echo "Downloading authorized_keys from $SSH_REMOTE..."
scp "$SSH_REMOTE:~/.ssh/authorized_keys" "$TEMP_FILE"

# Edit the file
${EDITOR:-vi} "$TEMP_FILE"

# Ask for confirmation before uploading
read -p "Upload changes back to $SSH_REMOTE? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Uploading modified authorized_keys..."
    scp "$TEMP_FILE" "$SSH_REMOTE:~/.ssh/authorized_keys"
    echo "Done!"
else
    echo "Changes discarded."
fi

