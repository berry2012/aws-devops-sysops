



export CLOUD9_ID=($(aws cloud9 list-environments --query 'environmentIds[0]' --output text))

echo "Identified the Cloud9 envs ${CLOUD9_ID} "

grep 'export CLOUD9_ID=' /home/ec2-user/.bash_profile

CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
   echo "export CLOUD9_ID=${CLOUD9_ID}" | tee -a /home/ec2-user/.bash_profile
fi

echo "aws cloud9 update-environment  --environment-id ${CLOUD9_ID} --managed-credentials-action DISABLE > /dev/null 2>&1" |  tee -a /home/ec2-user/.bash_profile


export C9_IDS=($(aws cloud9 list-environments | jq -r '.environmentIds | join(" ")'))
export CLOUD9_ID=($(aws cloud9 describe-environments --environment-ids ${C9_IDS} | jq -r '.environments[] | select(.name == "WorkshopWorkspace") | .id'))
echo "Identified the following Cloud9 envs ${C9_IDS}, selected ${CLOUD9_ID}"
grep 'export CLOUD9_ID=' /home/ec2-user/.bash_profile
CMDEXEC=$?
if [ $CMDEXEC -ne 0 ]; then
   echo "export CLOUD9_ID=${C9_ID}" | tee -a /home/ec2-user/.bash_profile
fi
echo "aws cloud9 update-environment  --environment-id ${CLOUD9_ID} --managed-credentials-action DISABLE > /dev/null 2>&1" |  tee -a /home/ec2-user/.bash_profile
