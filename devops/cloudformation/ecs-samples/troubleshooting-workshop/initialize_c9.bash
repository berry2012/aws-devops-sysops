#!/bin/bash


set -e

if [[ ! -d "~/.bashrc.d" ]]; then
  mkdir -p ~/.bashrc.d
  
  touch ~/.bashrc.d/test.bash

  echo 'for file in ~/.bashrc.d/*.bash; do source "$file"; done' >> ~/.bashrc
fi

if [ ! -z "$C9_PID" ]; then
  echo "aws cloud9 update-environment --environment-id $C9_PID --managed-credentials-action DISABLE &> /dev/null || true" > ~/.bashrc.d/c9.bash
  aws cloud9 update-environment --environment-id $C9_PID --managed-credentials-action DISABLE &> /dev/null
fi

export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')

cat << EOT > ~/.bashrc.d/env.bash
export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

export ECS_VPC_ID=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`ECSTroubleshootingVPC`].OutputValue')

export ECS_PRIVATESUBNET1_ID=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`PrivateSubnet1`].OutputValue')

export ECS_PRIVATESUBNET2_ID=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`PrivateSubnet2`].OutputValue')

export ECS_PUBLICSUBNET1_ID=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`PublicSubnet1`].OutputValue')

export ECS_PUBLICSUBNET2_ID=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`PublicSubnet2`].OutputValue')

export CONTAINER_INSTANCE_SECURITYGROUP=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`ContainerInstanceSecurityGroup`].OutputValue')

export EC2_CONTAINER_INSTANCEROLE=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`EC2ContainerInstanceRole`].OutputValue')

export ECS_SERVICE_SECURITYGROUP=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`ECSServiceSecurityGroup`].OutputValue')

export ELB_SECURITYGROUP=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`ELBSecurityGroup`].OutputValue')

export SUBNETS_PRIVATE=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`SubnetsPrivate`].OutputValue')

export SUBNETS_PUBLIC=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`SubnetsPublic`].OutputValue')

export TASK_EXECUTION_ROLE=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`TaskExecutionRole`].OutputValue')

export CLUSTER_NAME=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`ClusterName`].OutputValue')

export ADV_CLUSTER_NAME=$(aws cloudformation describe-stacks --stack-name ecs-troubleshooting \
--region $AWS_REGION --output text \
--query 'Stacks[0].Outputs[?OutputKey==`AdvClusterName`].OutputValue')
EOT

