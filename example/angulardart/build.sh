#!/bin/bash

set -eo pipefail

CDK_OUTPUTS=infra/outputs.json
BUCKET_NAME=$(cat ${CDK_OUTPUTS} | jq -r .FTAuthTodosStack.BucketName)
DISTRIBUTION_ID=$(cat ${CDK_OUTPUTS} | jq -r .FTAuthTodosStack.CloudFrontDistributionId)

dart pub get
dart pub global activate webdev
dart pub global run webdev build

aws s3 sync build s3://$BUCKET_NAME --delete
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" >/dev/null