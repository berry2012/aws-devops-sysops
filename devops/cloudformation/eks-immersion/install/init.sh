echo "Start Installation and Configuration of Cloud9"

export LOG_FILE="/tmp/cloud9-configurescript-log.txt"
sudo yum -y update

echo "Update AWS CLI and utilities"

sudo pip3 install awscli --upgrade --user && hash -r

sudo yum -y install jq gettext bash-completion moreutils

echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc

export AWS_DEFAULT_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$AWS_DEFAULT_REGION
grep 'export ACCOUNT_ID=' /home/ec2-user/.bash_profile
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
   echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a /home/ec2-user/.bash_profile
fi
grep 'export AWS_REGION=' /home/ec2-user/.bash_profile
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
   echo "export AWS_REGION=${AWS_REGION}" | tee -a /home/ec2-user/.bash_profile
fi
grep 'export AWS_DEFAULT_REGION=' /home/ec2-user/.bash_profile
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
   echo "export AWS_DEFAULT_REGION=${AWS_REGION}" | tee -a /home/ec2-user/.bash_profile
fi
aws configure set default.region ${AWS_REGION}
aws configure get default.region
export AZS=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION)

function log {
   echo "$1 -> $2" >> $LOG_FILE
}

export C9_IDS=($(aws cloud9 list-environments | jq -r '.environmentIds | join(" ")'))
export CLOUD9_ID=($(aws cloud9 describe-environments --environment-ids ${C9_IDS} | jq -r '.environments[] | select(.name == "WorkshopWorkspace") | .id'))
echo "Identified the following Cloud9 envs ${C9_IDS}, selected ${CLOUD9_ID}"
grep 'export CLOUD9_ID=' /home/ec2-user/.bash_profile
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
   echo "export CLOUD9_ID=${C9_ID}" | tee -a /home/ec2-user/.bash_profile
fi
