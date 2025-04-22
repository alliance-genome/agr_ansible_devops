#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Step 1: Copy the release-specific YAML file ---
# Assumes the script is run from the root directory (agr_ansible_devops)
# and the file is in a 'releases' subdirectory. Needs NEW_RELEASE_NUMBER env var.

# Check if the required environment variable is set
if [ -z "${NEW_RELEASE_NUMBER}" ]; then
    echo "Error: NEW_RELEASE_NUMBER environment variable is not set."
    exit 1
fi

SOURCE_YAML="releases/launch_${NEW_RELEASE_NUMBER}.yml"
DEST_YAML="launch_${NEW_RELEASE_NUMBER}.yml" # Copy to current directory

echo "Attempting to copy playbook: ${SOURCE_YAML} to ${DEST_YAML}"

# Check if the source file exists before trying to copy
if [ -f "${SOURCE_YAML}" ]; then
    cp "${SOURCE_YAML}" "${DEST_YAML}"
    echo "Successfully copied ${DEST_YAML}"
else
    echo "Error: Source playbook file not found at ${SOURCE_YAML}"
    exit 1 # Fail the job if the required playbook isn't found
fi

echo "Copy complete."
exit 0 # Explicitly exit successfully