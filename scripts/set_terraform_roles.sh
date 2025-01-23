#!/bin/bash
#
# Set the roles for the Terraform user.
#
#   Usage:
#     set_terraform_roles.sh --profile <AWS_PROFILE>
#     set_terraform_roles.sh -p <AWS_PROFILE>
#

GROUP_NAME="terraform"
POLICY_ARNS="arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

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

# Attach IAM policies to the group
echo "Attaching policies to group: $GROUP_NAME : $POLICY_ARNS"

for POLICY_ARN in $POLICY_ARNS; do
  if aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN" --profile "$profile" >/dev/null 2>&1; then
    echo "Policy ( $POLICY_ARN ) attached to group: $GROUP_NAME"
  else
    err "Error: Failed to attach policy $POLICY_ARN to group $GROUP_NAME."
  fi
done
