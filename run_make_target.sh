#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Perform the substitution
MAKE_TARGET="${NEW_RELEASE_NUMBER//./_}"

echo "Original NEW_RELEASE_NUMBER: ${NEW_RELEASE_NUMBER}"
echo "Running make target: ${MAKE_TARGET}"

# Execute the make command with the transformed target
make "${MAKE_TARGET}"