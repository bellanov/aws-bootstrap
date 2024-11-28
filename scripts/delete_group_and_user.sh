#!/bin/bash
set -e

# Dynamic variables for group name and IAM username
GROUP_NAME="${GROUP_NAME:-shell-group}"
USER_NAME="${USER_NAME:-my-service-account}"

echo "Deleting resources for group: $GROUP_NAME and user: $USER_NAME..."

# Detach policies from the group
POLICIES=$(aws iam list-attached-group-policies --group-name "$GROUP_NAME" --query 'AttachedPolicies[].PolicyArn' --output text --profile admin)
for POLICY_ARN in $POLICIES; do
  echo "Detaching policy $POLICY_ARN from group $GROUP_NAME..."
  aws iam detach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN" --profile admin
done

# Remove the user from the group
echo "Removing user $USER_NAME from group $GROUP_NAME..."
aws iam remove-user-from-group --group-name "$GROUP_NAME" --user-name "$USER_NAME" --profile admin

# Delete the user
echo "Deleting IAM user: $USER_NAME..."
aws iam delete-user --user-name "$USER_NAME" --profile admin

# Delete the group
echo "Deleting IAM group: $GROUP_NAME..."
aws iam delete-group --group-name "$GROUP_NAME" --profile admin

echo "Resources deleted successfully."
