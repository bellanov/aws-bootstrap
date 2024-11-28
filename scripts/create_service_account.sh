#!/bin/bash
set -e  # Exit on error
# creates a service account without any permissions
# Dynamic variable for the user name, with a default value
SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:-my-service-account}"

echo "Creating IAM user without any attached policies: $SERVICE_ACCOUNT_NAME..."

# Create the IAM user without attaching any policies
if aws iam create-user --user-name "$SERVICE_ACCOUNT_NAME" >/dev/null 2>&1; then
  echo "Successfully created user: $SERVICE_ACCOUNT_NAME without any permissions."
else
  echo "Error: Failed to create user $SERVICE_ACCOUNT_NAME." >&2
  exit 1
fi

echo "IAM user setup completed successfully. Assign permissions through a user group as needed."
