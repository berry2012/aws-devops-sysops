


aws --region "${REGION}" \
    cloudformation deploy \
    --stack-name "${ENVIRONMENT_NAME}-ecs-cluster" \
    --capabilities CAPABILITY_IAM \
    --template-file "${DIR}/ecs-cluster.yaml"  \
    --parameter-overrides \
    EnvironmentName="${ENVIRONMENT_NAME}" \
    KeyName="${KEY_PAIR_NAME}" 


export REGION=eu-west-1
export ENVIRONMENT_NAME=ecs-troubleshooting
DIR=/Users/eoalola/Documents/aws_works/ECS/ecs-samples-cf/troubleshooting-workshop
IAM_Role="arn:aws:iam::476367868464:role/Admin"

aws --region "${REGION}" \
    cloudformation deploy \
    --stack-name "${ENVIRONMENT_NAME}" \
    --capabilities CAPABILITY_IAM \
    --template-file "${DIR}/aws-ecs-troubleshooting.yaml"  \
    --parameter-overrides \
    EnvironmentName="${ENVIRONMENT_NAME}" \
    EETeamRoleArn="${IAM_Role}" \
    --profile staging


aws --region "${REGION}" \
    cloudformation delete-stack \
    --stack-name "${ENVIRONMENT_NAME}" \
    --profile staging

