#!/usr/bin/env bash
# Creates the S3 bucket and DynamoDB table used as Terraform remote backend for AWS.
# Run this ONCE before the first `terraform init`.
#
# Usage: ./bootstrap-backend.sh <aws-account-id> <environment> [region]
# Example: ./bootstrap-backend.sh 123456789012 dev us-east-1

set -euo pipefail

AWS_ACCOUNT_ID="${1:?Arg 1: AWS account ID}"
ENVIRONMENT="${2:?Arg 2: environment}"
REGION="${3:-us-east-1}"

BUCKET_NAME="tfstate-${AWS_ACCOUNT_ID}-${ENVIRONMENT}"
DYNAMODB_TABLE="tf-state-lock-${ENVIRONMENT}"

echo "==> Creating S3 backend bucket: $BUCKET_NAME"
if [ "$REGION" = "us-east-1" ]; then
  # us-east-1 does NOT accept LocationConstraint (AWS quirk)
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION"
else
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

echo "==> Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "==> Enabling server-side encryption (AES256)..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"},
      "BucketKeyEnabled": true
    }]
  }'

echo "==> Blocking all public access on backend bucket..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "==> Creating DynamoDB table for state locking: $DYNAMODB_TABLE"
aws dynamodb create-table \
  --table-name "$DYNAMODB_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" \
  --output none 2>/dev/null || echo "   Table already exists — skipping."

echo ""
echo "=== Backend created. Use these values in ADO variable group: iac-tf-aws-backend ==="
echo "TF_BACKEND_BUCKET:   $BUCKET_NAME"
echo "TF_BACKEND_REGION:   $REGION"
echo "TF_BACKEND_DYNAMODB: $DYNAMODB_TABLE"
echo ""
echo "=== Example terraform init ==="
echo "terraform init \\"
echo "  -backend-config=\"bucket=$BUCKET_NAME\" \\"
echo "  -backend-config=\"key=aws-demo/$ENVIRONMENT.tfstate\" \\"
echo "  -backend-config=\"region=$REGION\" \\"
echo "  -backend-config=\"dynamodb_table=$DYNAMODB_TABLE\" \\"
echo "  -backend-config=\"encrypt=true\""
