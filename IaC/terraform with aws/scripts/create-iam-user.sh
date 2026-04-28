#!/usr/bin/env bash
# Creates an IAM user with least-privilege permissions for Terraform AWS deployments.
# For CI/CD, consider using IAM Role with OIDC instead (see README).
#
# Usage: ./create-iam-user.sh <environment> <backend-bucket-name> <dynamodb-table-name>
# Example: ./create-iam-user.sh dev tfstate-123456789012-dev tf-state-lock-dev

set -euo pipefail

ENVIRONMENT="${1:?Arg 1: environment}"
BACKEND_BUCKET="${2:?Arg 2: backend S3 bucket name}"
DYNAMODB_TABLE="${3:?Arg 3: DynamoDB table name}"

IAM_USER="tf-aws-${ENVIRONMENT}"
POLICY_NAME="TerraformAWSDemoPolicy-${ENVIRONMENT}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "==> Creating IAM user: $IAM_USER"
aws iam create-user --user-name "$IAM_USER" --output none 2>/dev/null || \
  echo "   User already exists — skipping create."

echo "==> Creating inline policy: $POLICY_NAME"
aws iam put-user-policy \
  --user-name "$IAM_USER" \
  --policy-name "$POLICY_NAME" \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Sid\": \"EC2VPCManage\",
        \"Effect\": \"Allow\",
        \"Action\": [
          \"ec2:*Vpc*\", \"ec2:*Subnet*\", \"ec2:*InternetGateway*\",
          \"ec2:*RouteTable*\", \"ec2:*SecurityGroup*\", \"ec2:*Instance*\",
          \"ec2:*KeyPair*\", \"ec2:Describe*\", \"ec2:*Tags*\",
          \"ec2:*BlockDevice*\", \"ec2:*NetworkInterface*\"
        ],
        \"Resource\": \"*\"
      },
      {
        \"Sid\": \"S3DataBucket\",
        \"Effect\": \"Allow\",
        \"Action\": [\"s3:*\"],
        \"Resource\": [
          \"arn:aws:s3:::demo-data-*\",
          \"arn:aws:s3:::demo-data-*/*\"
        ]
      },
      {
        \"Sid\": \"TFStateS3\",
        \"Effect\": \"Allow\",
        \"Action\": [
          \"s3:GetObject\", \"s3:PutObject\", \"s3:DeleteObject\",
          \"s3:ListBucket\", \"s3:GetBucketVersioning\"
        ],
        \"Resource\": [
          \"arn:aws:s3:::${BACKEND_BUCKET}\",
          \"arn:aws:s3:::${BACKEND_BUCKET}/*\"
        ]
      },
      {
        \"Sid\": \"TFStateDynamoDB\",
        \"Effect\": \"Allow\",
        \"Action\": [
          \"dynamodb:GetItem\", \"dynamodb:PutItem\",
          \"dynamodb:DeleteItem\", \"dynamodb:DescribeTable\"
        ],
        \"Resource\": \"arn:aws:dynamodb:*:${AWS_ACCOUNT_ID}:table/${DYNAMODB_TABLE}\"
      }
    ]
  }"

echo "==> Creating access key for $IAM_USER..."
KEY_JSON=$(aws iam create-access-key --user-name "$IAM_USER" --output json)
ACCESS_KEY_ID=$(echo "$KEY_JSON" | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo "$KEY_JSON" | jq -r '.AccessKey.SecretAccessKey')

echo ""
echo "=== Store in ADO Library variable group: iac-tf-aws-secrets (mark as Secret) ==="
echo "AWS_ACCESS_KEY_ID:     $ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $SECRET_KEY"
echo ""
echo "=== Or export for local Terraform runs ==="
echo "export AWS_ACCESS_KEY_ID=\"$ACCESS_KEY_ID\""
echo "export AWS_SECRET_ACCESS_KEY=\"$SECRET_KEY\""
echo "export AWS_DEFAULT_REGION=\"us-east-1\""
