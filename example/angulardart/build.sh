#!/bin/bash

set -eo pipefail

CDK_OUTPUTS=infra/outputs.json
BUCKET_NAME=$(cat ${CDK_OUTPUTS} | jq -r .FTAuthTodosStack.BucketName)
DISTRIBUTION_ID=$(cat ${CDK_OUTPUTS} | jq -r .FTAuthTodosStack.CloudFrontDistributionId)

dart pub get
# TODO: Reactivate when webdev is fixed: https://github.com/dart-lang/webdev/issues/1482
# dart pub global activate webdev 2.7.6
# dart pub global run webdev build
dart run webdev build

aws s3 sync build s3://$BUCKET_NAME --delete
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" >/dev/null