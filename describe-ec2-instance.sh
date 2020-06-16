#!/bin/bash



INSTANCE_ID=$(aws ec2 describe-instances \
    --filter Name=tag:Name,Values=$INSTANCE_NAME \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,Status:State.Name,Name:Tags[?Key==`Name`]|[0].Value}' \
    --region $REGION \
    --output text | grep 'running' | awk -F' ' '{print $1}')

echo $INSTANCE_ID >> output.txt


# use ssm to run the EC2 instance
# aws ssm start-session --target $INSTANCE_ID --region $REGION

#Bonus 
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' --region $REGION --output table
