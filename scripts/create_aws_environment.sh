#!/bin/bash
#
# Initialize an AWS Enivironment.
#
#   Usage:
#     create_aws_environment.sh --profile <AWS_PROFILE> 
#     create_aws_environment.sh -p <AWS_PROFILE>
#

# Environment Configuration
SERVICE_ACCOUNT="terraform"
GROUP_NAME="terraform"
POLICY_ARNS="arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

# Exit on error
set -e

#######################################
# Display an error message to STDERR.
# Globals:
#   None
# Arguments:
#   String containing the error message.
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

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

# Create the Terraform User
echo "Creating IAM User: $SERVICE_ACCOUNT"

if aws iam create-user --user-name "$SERVICE_ACCOUNT" --profile "$profile" >/dev/null 2>&1; then
  echo "Successfully created user: $SERVICE_ACCOUNT"
else
  err "Error: Failed to create user $SERVICE_ACCOUNT"
fi

# Create the Terraform user group
echo "Creating IAM user group: $GROUP_NAME"

if aws iam create-group --group-name "$GROUP_NAME" --profile "$profile" >/dev/null 2>&1; then
  echo "Successfully created group: $GROUP_NAME"
else
  err "Error: Failed to create group $GROUP_NAME."
fi

# Add the user to the group
echo "Adding user to group: $SERVICE_ACCOUNT => $GROUP_NAME"

if aws iam add-user-to-group --group-name "$GROUP_NAME" --user-name "$SERVICE_ACCOUNT" --profile "$profile" >/dev/null 2>&1; then
  echo "User $SERVICE_ACCOUNT successfully added to group: $GROUP_NAME"
else
  err "Error: Failed to add user $SERVICE_ACCOUNT to group: $GROUP_NAME"
fi

# Attach IAM policies to the group
echo "Attaching policies to group: $GROUP_NAME : $POLICY_ARNS"

for POLICY_ARN in $POLICY_ARNS; do
  if aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN" --profile "$profile" >/dev/null 2>&1; then
    echo "Policy ( $POLICY_ARN ) attached to group: $GROUP_NAME"
  else
    err "Error: Failed to attach policy $POLICY_ARN to group $GROUP_NAME."
  fi
done

# Generate a new access key and secret key for the user
echo "Generating new access key for service account: $SERVICE_ACCOUNT"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$SERVICE_ACCOUNT" --output json --profile "$profile")

# Parse and display the Access Key ID and Secret Access Key
ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.SecretAccessKey')

echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"

# Project Creation Complete
echo "Environment creation complete!!!"