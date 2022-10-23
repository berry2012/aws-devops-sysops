#!/bin/bash 

# verify that your script completed without errors - /var/log/cloud-init-output.log
# or redirects the user-data output:
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    sudo yum update -y
    sudo yum install ruby -y
    sudo yum install wget -y
    cd /home/ec2-user
    wget https://aws-codedeploy-eu-west-1.s3.amazonaws.com/latest/install
    chmod +x ./install
    sudo ./install auto
    sudo service codedeploy-agent status
    if [[ $? == 1 ]]; then
        sudo service codedeploy-agent start
    else
         echo "codedeploy-agent installation succeeded!"
    fi
