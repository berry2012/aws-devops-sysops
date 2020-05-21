#!/bin/bash


INSTANCE_ID=$(aws ec2 describe-instances \
    --filter Name=tag:Name,Values=$INSTANCE_NAME \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,Status:State.Name,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output text | grep 'running' | awk -F' ' '{print $1}')

ssm $INSTANCE_ID

