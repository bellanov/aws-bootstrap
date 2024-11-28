#!/bin/bash
set -e  # Exit on error

# Variables
SERVICE_ACCOUNT_NAME="my-service-account"  # Name of the IAM user

# Check if the service account exists
if ! aws iam get-user --user-name "$SERVICE_ACCOUNT_NAME" >/dev/null 2>&1; then
  echo "Error: Service account $SERVICE_ACCOUNT_NAME does not exist." >&2
  exit 1
fi

# Generate a new access key and secret key for the user
echo "Generating new access key for service account: $SERVICE_ACCOUNT_NAME..."
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$SERVICE_ACCOUNT_NAME" --output json)

# Parse and display the Access Key ID and Secret Access Key
ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.SecretAccessKey')

echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"

# Save the keys to a secure file (optional)
OUTPUT_FILE="${SERVICE_ACCOUNT_NAME}_credentials.txt"
echo -e "Access Key ID: $ACCESS_KEY_ID\nSecret Access Key: $SECRET_ACCESS_KEY" > "$OUTPUT_FILE"
chmod 600 "$OUTPUT_FILE"  # Make the file readable only by the owner
echo "Credentials saved to $OUTPUT_FILE"

echo "Access key generation completed successfully."
