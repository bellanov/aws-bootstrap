#!/bin/bash
set -e  # Exit on error

SERVICE_ACCOUNT_NAME="my-service-account"
POLICY_ARN="arn:aws:iam::aws:policy/AmazonQDeveloperAccess"

echo "Starting AWS service account setup..."

# Creating user
if aws iam create-user --user-name "$SERVICE_ACCOUNT_NAME"  >/dev/null 2>&1; then
  echo "Successfully created user: $SERVICE_ACCOUNT_NAME"
else
  echo "Error: Failed to create user." >&2
  exit 1
fi

# Attaching policy
if aws iam attach-user-policy --user-name "$SERVICE_ACCOUNT_NAME" --policy-arn  "$POLICY_ARN"; then
  echo "Policy attached successfully to user: $SERVICE_ACCOUNT_NAME"
else
  echo "Error: Failed to attach policy to user." >&2
  exit 1
fi

echo "Service account setup completed successfully."
