#!/bin/bash
set -e

# Dynamic group name provided via environment variable or defaults to "shell-group"
GROUP_NAME="${GROUP_NAME:-shell-group}"

echo "Creating IAM user group: $GROUP_NAME..."

if aws iam create-group --group-name "$GROUP_NAME" >/dev/null 2>&1; then
  echo "Successfully created group: $GROUP_NAME"
else
  echo "Error: Failed to create group $GROUP_NAME." >&2
  exit 1
fi
