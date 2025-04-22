#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Prepare and run the make target ---
# Perform the substitution for the make target name
MAKE_TARGET="${NEW_RELEASE_NUMBER//./_}"

echo "Original NEW_RELEASE_NUMBER: ${NEW_RELEASE_NUMBER}"
echo "Running make target: ${MAKE_TARGET}"

# Execute the make command with the transformed target
make "${MAKE_TARGET}"

echo "Make command finished."
exit 0