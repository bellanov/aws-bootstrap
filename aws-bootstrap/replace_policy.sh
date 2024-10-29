#!/bin/bash
set -e  # Exit on error

# Variables
SERVICE_ACCOUNT_NAME="my-service-account"   # Name of the service account to modify
NEW_POLICY_ARN="arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # ARN of the new policy

# Start
echo "Starting policy replacement for service account: $SERVICE_ACCOUNT_NAME"

# Check if the service account exists
if ! aws iam get-user --user-name "$SERVICE_ACCOUNT_NAME" >/dev/null 2>&1; then
  echo "Error: Service account $SERVICE_ACCOUNT_NAME does not exist." >&2
  exit 1
fi

# List and detach all existing policies
echo "Detaching existing policies from $SERVICE_ACCOUNT_NAME..."
POLICY_ARNS=$(aws iam list-attached-user-policies --user-name "$SERVICE_ACCOUNT_NAME" --query 'AttachedPolicies[].PolicyArn' --output text )

if [ -n "$POLICY_ARNS" ]; then
  for POLICY_ARN in $POLICY_ARNS; do
    aws iam detach-user-policy --user-name "$SERVICE_ACCOUNT_NAME" --policy-arn "$POLICY_ARN"
    echo "Detached policy: $POLICY_ARN"
  done
else
  echo "No existing policies attached to $SERVICE_ACCOUNT_NAME."
fi

# Attach the new policy
echo "Attaching new policy $NEW_POLICY_ARN to $SERVICE_ACCOUNT_NAME..."
if aws iam attach-user-policy --user-name "$SERVICE_ACCOUNT_NAME" --policy-arn "$NEW_POLICY_ARN"; then
  echo "Policy $NEW_POLICY_ARN attached successfully to $SERVICE_ACCOUNT_NAME."
else
  echo "Error: Failed to attach policy $NEW_POLICY_ARN to $SERVICE_ACCOUNT_NAME." >&2
  exit 1
fi

echo "Policy replacement completed successfully for $SERVICE_ACCOUNT_NAME."
