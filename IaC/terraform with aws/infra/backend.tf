# Partial backend configuration — values supplied at `terraform init` time.
# S3 for state storage + DynamoDB for state locking (prevents concurrent applies).
#
# Init command:
#   terraform init \
#     -backend-config="bucket=<TF_BACKEND_BUCKET>" \
#     -backend-config="key=aws-demo/<environment>.tfstate" \
#     -backend-config="region=<AWS_REGION>" \
#     -backend-config="dynamodb_table=<TF_BACKEND_DYNAMODB>" \
#     -backend-config="encrypt=true"

terraform {
  backend "s3" {
    # All values injected at init time — nothing hardcoded here.
  }
}
