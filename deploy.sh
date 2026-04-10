#!/bin/bash
# Deploy Hallvardbo to S3 + invalidate CloudFront cache
# Usage: ./deploy.sh [stack-name]
#
# Prerequisites:
#   1. AWS CLI configured (aws configure)
#   2. CloudFormation stack deployed (see README)

set -e

STACK_NAME="${1:-hallvardbo-site}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get bucket name and distribution ID from CloudFormation outputs
echo "==> Fetching stack outputs from '$STACK_NAME'..."
BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" --output text)
DIST_ID=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" --output text)

if [ -z "$BUCKET" ] || [ "$BUCKET" = "None" ]; then
  echo "Error: Could not find S3 bucket. Is the stack '$STACK_NAME' deployed?"
  exit 1
fi

echo "    Bucket:       $BUCKET"
echo "    Distribution: $DIST_ID"

# Optimize images if script exists (non-fatal)
if [ -f "$SCRIPT_DIR/optimize-images.sh" ]; then
  echo "==> Optimizing images..."
  bash "$SCRIPT_DIR/optimize-images.sh" || echo "    Skipping image optimization."
fi

# Sync site files to S3
echo "==> Syncing files to s3://$BUCKET..."
aws s3 sync "$SCRIPT_DIR" "s3://$BUCKET" \
  --delete \
  --exclude '.git/*' \
  --exclude '.gitignore' \
  --exclude 'deploy.sh' \
  --exclude 'optimize-images.sh' \
  --exclude 'cloudformation.yaml' \
  --exclude 'README.md' \
  --exclude '.DS_Store' \
  --exclude '.claude/*'

# Set cache-control headers
echo "==> Setting cache headers..."
aws s3 cp "s3://$BUCKET" "s3://$BUCKET" \
  --recursive --exclude '*' --include '*.html' \
  --cache-control 'max-age=300, must-revalidate' \
  --content-type 'text/html' --metadata-directive REPLACE --quiet

aws s3 cp "s3://$BUCKET" "s3://$BUCKET" \
  --recursive --exclude '*' --include 'css/*' \
  --cache-control 'max-age=604800' \
  --content-type 'text/css' --metadata-directive REPLACE --quiet

aws s3 cp "s3://$BUCKET" "s3://$BUCKET" \
  --recursive --exclude '*' --include 'js/*' \
  --cache-control 'max-age=604800' \
  --content-type 'application/javascript' --metadata-directive REPLACE --quiet

aws s3 cp "s3://$BUCKET" "s3://$BUCKET" \
  --recursive --exclude '*' --include 'images/*' \
  --cache-control 'max-age=2592000' \
  --metadata-directive REPLACE --quiet

# Invalidate CloudFront cache
if [ -n "$DIST_ID" ] && [ "$DIST_ID" != "None" ]; then
  echo "==> Invalidating CloudFront cache..."
  aws cloudfront create-invalidation \
    --distribution-id "$DIST_ID" \
    --paths '/*' --query 'Invalidation.Id' --output text
fi

echo "==> Done! Site deployed."
