#!/bin/bash
set -e

# Dynamic variables for group name and IAM username
GROUP_NAME="${GROUP_NAME:-shell-group}"
USER_NAME="${USER_NAME:-my-service-account}"

echo "Adding user $USER_NAME to group $GROUP_NAME..."

# Add the user to the group
if aws iam add-user-to-group --group-name "$GROUP_NAME" --user-name "$USER_NAME"; then
  echo "User $USER_NAME successfully added to group $GROUP_NAME."
else
  echo "Error: Failed to add user $USER_NAME to group $GROUP_NAME." >&2
  exit 1
fi
