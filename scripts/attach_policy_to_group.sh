#!/bin/bash
set -e

# Dynamic variables for group name and policy ARN
GROUP_NAME="${GROUP_NAME:-shell-group}"
POLICY_ARN="${POLICY_ARN:-arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess}"

echo "Attaching policy $POLICY_ARN to group $GROUP_NAME..."

if aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN"; then
  echo "Policy $POLICY_ARN attached to group $GROUP_NAME successfully."
else
  echo "Error: Failed to attach policy $POLICY_ARN to group $GROUP_NAME." >&2
  exit 1
fi
