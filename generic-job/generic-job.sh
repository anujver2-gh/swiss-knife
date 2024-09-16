#!/bin/bash

if [[ $aws_env == 'china-dev' ]]; then
    echo "Building for China Dev environment"
    export AWS_ACCESS_KEY_ID=$china_dev_id
    export AWS_SECRET_ACCESS_KEY=$china_dev_key
    export AWS_ECR='114040874283.dkr.ecr.cn-northwest-1.amazonaws.com.cn'
    export AWS_REGION='cn-northwest-1'
    export CHINA_IAM_ROLE='arn:aws-cn:iam::114040874283:role/CICDBotRole'
elif [[ $aws_env == 'china-prod' ]]; then
    echo "Building for China Prod environment"
    export AWS_ACCESS_KEY_ID=$china_prod_id
    export AWS_SECRET_ACCESS_KEY=$china_prod_key
    export AWS_ECR='146618076670.dkr.ecr.cn-north-1.amazonaws.com.cn'
    export AWS_REGION='cn-north-1'
    export CHINA_IAM_ROLE='arn:aws-cn:iam::146618076670:role/CICDBotRole'
    export CHINA_PROD_CRED_ID='cicdbotuser-china-prod-creds'
elif [[ $aws_env == 'commercial-dev' ]]; then
    echo "Building for commercial dev environment"
    export AWS_ECR='072824598875.dkr.ecr.us-west-2.amazonaws.com'
    export AWS_REGION='us-west-2'
    export AWS_ROLE='jenkins-sift-cdaas'
else
    echo "select aws_env ${aws_env} is not supported"
    exit
fi

echo "china env: $aws_env"
echo "Logging into AWS ECR!..🔐"

export AWS_DEFAULT_REGION=${AWS_REGION}
if [[ $aws_env == 'china-dev' || $aws_env == 'china-prod' ]]; then
    assume_role_output=$(aws sts assume-role \
      --role-arn "${CHINA_IAM_ROLE}" \
      --role-session-name AWSCLI-Session 2>/dev/null)
    export AWS_ACCESS_KEY_ID=$(echo "$assume_role_output" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$assume_role_output" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$assume_role_output" | jq -r '.Credentials.SessionToken')
    aws ecr get-login-password --region ${AWS_REGION} | docker login -u AWS --password-stdin https://${AWS_ECR}/
    echo "Successfully logged into AWS ECR!..🔓"
fi

## if commercial stage no need to login , its already logged in
docker pull 146618076670.dkr.ecr.cn-north-1.amazonaws.com.cn/china/generic:swiss-knife
docker push $AWS_ECR/china/generic:swiss-knife