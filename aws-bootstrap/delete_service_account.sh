#!/bin/bash
set -e  # Exit on error

# Variables
SERVICE_ACCOUNT_NAME="my-service-account"  # Name of the service account to delete

echo "Starting deletion of service account: $SERVICE_ACCOUNT_NAME"

# Check if the service account exists
if ! aws iam get-user --user-name "$SERVICE_ACCOUNT_NAME" >/dev/null 2>&1; then
  echo "Error: Service account $SERVICE_ACCOUNT_NAME does not exist." >&2
  exit 1
fi

# Detach all managed policies attached to the service account
echo "Detaching managed policies from $SERVICE_ACCOUNT_NAME..."
POLICY_ARNS=$(aws iam list-attached-user-policies --user-name "$SERVICE_ACCOUNT_NAME" --query 'AttachedPolicies[].PolicyArn' --output text)
for POLICY_ARN in $POLICY_ARNS; do
  aws iam detach-user-policy --user-name "$SERVICE_ACCOUNT_NAME" --policy-arn "$POLICY_ARN"
  echo "Detached policy: $POLICY_ARN"
done

# Delete all inline policies attached to the service account
echo "Deleting inline policies from $SERVICE_ACCOUNT_NAME..."
INLINE_POLICIES=$(aws iam list-user-policies --user-name "$SERVICE_ACCOUNT_NAME" --query 'PolicyNames' --output text)
for POLICY_NAME in $INLINE_POLICIES; do
  aws iam delete-user-policy --user-name "$SERVICE_ACCOUNT_NAME" --policy-name "$POLICY_NAME"
  echo "Deleted inline policy: $POLICY_NAME"
done

# Delete all access keys associated with the service account
echo "Deleting access keys for $SERVICE_ACCOUNT_NAME..."
ACCESS_KEYS=$(aws iam list-access-keys --user-name "$SERVICE_ACCOUNT_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text)
for ACCESS_KEY in $ACCESS_KEYS; do
  aws iam delete-access-key --user-name "$SERVICE_ACCOUNT_NAME" --access-key-id "$ACCESS_KEY"
  echo "Deleted access key: $ACCESS_KEY"
done

# Delete the service account
echo "Deleting service account $SERVICE_ACCOUNT_NAME..."
if aws iam delete-user --user-name "$SERVICE_ACCOUNT_NAME"; then
  echo "Service account $SERVICE_ACCOUNT_NAME deleted successfully."
else
  echo "Error: Failed to delete service account $SERVICE_ACCOUNT_NAME." >&2
  exit 1
fi

echo "Service account deletion process completed successfully."
