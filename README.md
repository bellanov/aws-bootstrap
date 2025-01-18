# aws-bootstrap

Bootstrap development in *Amazon Web Services*.

## Prerequisites

These scripts require the following:

- An existing *Amazon Web Services* ([link](https://aws.amazon.com/free/)) account.

## Scripts

Summary of the available scripts and their usage. Details available within each script.

| Script      | Description |
| ----------- | ----------- |
| **create_aws_environment.sh** | Initialize a new *AWS Environment* along with an initial *Terraform* identity. |
| **delete_aws_environment.sh** | Delete a AWS Environment and disable its billing. |
| **set_terraform_roles.sh** | Set the Terraform roles for a AWS Environment. |

## Examples

Various examples of script execution.

### create_gcp_environment.sh

This script creates a new *AWS Environment* and initializes it with an initial *Terraform* identity. Environments are used to isolate and organize infrastructure.

```sh
create_gcp_environment.sh --project <PROJECT_NAME> --organization <ORGANIZATION_ID> --billing <BILLING_ACCOUNT_ID>
# OR
# create_gcp_environment.sh -p <PROJECT_NAME> -o <ORGANIZATION_ID> -b <BILLING_ACCOUNT_ID>
```

An example of script execution.

```sh
scripts/create_gcp_environment.sh -p test-gcp-scripts -o "1234567890" -b "123ABCD-ABC1234-123ABCD"
Project Name  : test-gcp-scripts
Organization  : 1234567890
Billing       : 123ABCD-ABC1234-123ABCD
Debug         : warning
Creating project: test-gcp-scripts-1734665851
Successfully created project: test-gcp-scripts-1734665851
Setting active project to: test-gcp-scripts-1734665851
Successfully set active project: test-gcp-scripts-1734665851
Linking billing account: 123ABCD-ABC1234-123ABCD
Successfully linked billing account: 123ABCD-ABC1234-123ABCD
Enabling Service APIs: Cloud Resource Manager, Identity & Access Management, Secret Manager API
Enabling API: cloudresourcemanager.googleapis.com
Successfully enabled API: cloudresourcemanager.googleapis.com
...
```