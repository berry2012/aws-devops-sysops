

## Set Environment Variables

SECRET_ARN=arn:aws:secretsmanager:eu-west-1:520817024429:secret:sec-prod-mgmt/domain/database-pSoPZf
ENVIRONMENT_NAME=demo
AWS_DEFAULT_REGION=eu-west-1
APP_IMAGE_NAME=nginx
CERTIFICATE_ARN=arn:aws:acm:eu-west-1:520817024429:certificate/fcc58e38-dbf0-4f55-9d0e-955da11d2da0
KEY_PAIR_NAME=aws-wale.pem

chmod +x ecs-cluster.sh  ecs-service.sh  
bash ecs-cluster.sh



aws --region "${AWS_DEFAULT_REGION}" \
    cloudformation deploy \
    --stack-name "${ENVIRONMENT_NAME}-ecs-taskdef" \
    --capabilities CAPABILITY_IAM \
    --template-file "./taskdef.yml"  \
    --parameter-overrides \
    EnvironmentName="${ENVIRONMENT_NAME}" \
    AppImageName="${APP_IMAGE_NAME}" \
    SecretARN="${SECRET_ARN}"
