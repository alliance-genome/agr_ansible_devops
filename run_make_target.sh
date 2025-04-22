#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Step 1: Copy the release-specific YAML file ---
# Assumes the script is run from the root directory (agr_ansible_devops)
# and the file is in a 'releases' subdirectory.
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

# --- Step 2: Prepare and run the make target ---
# Perform the substitution for the make target name
MAKE_TARGET="${NEW_RELEASE_NUMBER//./_}"

echo "Original NEW_RELEASE_NUMBER: ${NEW_RELEASE_NUMBER}"
echo "Running make target: ${MAKE_TARGET}"

# Execute the make command with the transformed target
make "${MAKE_TARGET}"

# Optional: Clean up the copied file afterwards if needed
# echo "Cleaning up copied file: ${DEST_YAML}"
# rm "${DEST_YAML}"