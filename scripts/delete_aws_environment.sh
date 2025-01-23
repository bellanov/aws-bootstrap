#!/bin/bash
#
# Delete an AWS Enivironment.
#
#   Usage:
#     delete_aws_environment.sh --profile <AWS_PROFILE> 
#     delete_aws_environment.sh -p <AWS_PROFILE>
#

# Environment Configuration
SERVICE_ACCOUNT="terraform"
GROUP_NAME="terraform"

# Exit on error
set -e

#######################################
# Validate the arguments and initialize the script.
# Globals:
#   None.
# Arguments:
#   None.
#######################################
initialize() {

  # Validate the GCP Project argumeent
  if [ "$1" = "" ] ; then
    err "Error: AWS_PROFILE not provided or is invalid."
  fi

  # Initialize Verbosity
  if [ "$2" = "1" ] ; then
    debug="debug"
  else
    debug="warning"
  fi

  # Display validated arguments / parameters
  echo "AWS Profile   : $1"
  echo "Debug         : $debug"

}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
      -p|--profile) profile="$2"; shift ;;
      -d|--debug) debug=1 ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Initialize Script
initialize "$profile" "$debug"

# Detach policies from the Terraform group
echo "Detaching Group Policies: $GROUP_NAME"

POLICIES=$(aws iam list-attached-group-policies --group-name "$GROUP_NAME" --query 'AttachedPolicies[].PolicyArn' --output text --profile "$profile")

for POLICY_ARN in $POLICIES; do
  echo "Detaching policy ( $POLICY_ARN ) from group ( $GROUP_NAME )"

  if aws iam detach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN" \
    --profile "$profile" >/dev/null 2>&1; then
    echo "Successfully detached policy: $POLICY_ARN"
  else
    err "Error: Failed to create user $SERVICE_ACCOUNT"
  fi
done

# Remove the Terraform user from the group
echo "Removing user ( $SERVICE_ACCOUNT ) from group ( $GROUP_NAME )"
if aws iam remove-user-from-group --group-name "$GROUP_NAME" --user-name "$SERVICE_ACCOUNT" \
  --profile "$profile" >/dev/null 2>&1; then
  echo "Successfully removed user: $SERVICE_ACCOUNT"
else
  err "Error: Failed to remove user: $SERVICE_ACCOUNT"
fi

# Delete Terraform user access keys
echo "Deleting user access keys: $SERVICE_ACCOUNT"
ACCESS_KEYS=$(aws iam list-access-keys --user-name "$SERVICE_ACCOUNT" --query 'AccessKeyMetadata[].AccessKeyId' --output text --profile "$profile")

for ACCESS_KEY in $ACCESS_KEYS; do
  echo "Deleting access key: $ACCESS_KEY"
  if aws iam delete-access-key --user-name "$SERVICE_ACCOUNT" --access-key-id "$ACCESS_KEY" \
    --profile "$profile" >/dev/null 2>&1; then
    echo "Successfully deleted access key: $ACCESS_KEY"
  else
    err "Error: Failed to delete access key: $ACCESS_KEY"
  fi
done

# Delete the Terraform user
echo "Deleting IAM user: $SERVICE_ACCOUNT"

if aws iam delete-user --user-name "$SERVICE_ACCOUNT" --profile "$profile"  >/dev/null 2>&1; then
  echo "Successfully deleted user: $SERVICE_ACCOUNT"
else
  err "Error: Failed to delete user: $SERVICE_ACCOUNT"
fi

# Delete the Terraform user group
echo "Deleting IAM group: $GROUP_NAME"

if aws iam delete-group --group-name "$GROUP_NAME" --profile "$profile" >/dev/null 2>&1; then
  echo "Successfully deleted IAM group: $GROUP_NAME"
else
  err "Error: Failed to IAM group: $GROUP_NAME"
fi

# Project Deletion Complete
echo "Environment deletion complete!!!"
