# Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#title           eks-jam-ubuntu-init.sh
#description     This script will setup the Cloud9 IDE with the prerequisite packages and code for the EKS JAM for AppMod
#author          Jungseob Shin (@jungseob)
#date            2023-09-10
#version         0.1
#Refrence        origin from eksinit.sh from event engine boot strapping 
#usage           aws s3 cp s3://ee-assets-prod-us-east-1/modules/bd7b369f613f452dacbcea2a5d058d5b/v5/eksinit.sh . && chmod +x eksinit.sh && ./eksinit.sh ; source ~/.bash_profile ; source ~/.bashrc
#==============================================================================

###########################
##  Increase Volume Size ##
###########################

# Designate Desired volume size
SIZE=${1:-20}

# Get AWS Cloud9 instance ID
INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Get Amazon EBS ID associated with the instance 
VOLUMEID=$(aws ec2 describe-volumes \
--filters Name=attachment.instance-id,Values=$INSTANCEID \
--query "Volumes[0].VolumeId" \
--output text)

# Resize the EBS volume
aws ec2 modify-volume --volume-id $VOLUMEID --size $SIZE

while [ \
"$(aws ec2 describe-volumes-modifications \
    --volume-id $VOLUMEID \
    --filters Name=modification-state,Values="optimizing","completed" \
    --query "length(VolumesModifications)"\
    --output text)" != "1" ]; do
sleep 1
done

# Rewrite the partition table
sudo growpart /dev/nvme0n1 1

# Expand the size of the file system
sudo resize2fs /dev/nvme0n1p1

####################
##  Tools Install ##
####################

sudo apt-get update

# Install jq (json query)
sudo apt install -y jq

# Install yq (yaml query)
echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc

# Install other utils:
#   gettext: a framework to help other GNU packages product multi-language support. Part of GNU Translation Project.
#   bash-completion: supports command name auto-completion for supported commands
#   moreutils: a growing collection of the unix tools that nobody thought to write long ago when unix was young
sudo apt install -y gettext bash-completion moreutils

# Update awscli v1, just in case it's required
pip install --user --upgrade awscli

# Install awscli v2
rm /home/ubuntu/.local/bin/aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm awscliv2.zip

# Configure Cloud9 credentials
aws cloud9 update-environment  --environment-id $C9_PID --managed-credentials-action DISABLE
rm -vf ${HOME}/.aws/credentials

# Install kubectl & set kubectl as executable, move to path, populate kubectl bash-completion
curl -LO https://dl.k8s.io/release/v1.28.1/bin/linux/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(kubectl completion bash | sed 's/kubectl/k/g')" >> ~/.bashrc

# Install IAM Authenticator
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.11/aws-iam-authenticator_0.6.11_linux_amd64
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

# Install CDK
echo "installing cdk@2.91.0"
npm install -g aws-cdk@2.91.0 --force
echo "cdk --version"
cdk --version

# Install Typescript
if which tsc > /dev/null
    then
    echo "tsc --version"
    tsc --version
    else
    echo "installing typescript..."
    echo "npm install -g typescript"
    npm install -g typescript
fi

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Install aliases
echo "alias k='kubectl'" | tee -a ~/.bashrc
echo "alias kgp='kubectl get pods'" | tee -a ~/.bashrc
echo "alias kgsvc='kubectl get svc'" | tee -a ~/.bashrc
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a ~/.bashrc

######################
##  Set Variables   ##
######################

# Set AWS LB Controller version
echo 'export LBC_VERSION="v2.6.1"' >>  ~/.bash_profile
echo 'export LBC_CHART_VERSION="1.6.0"' >>  ~/.bash_profile

.  ~/.bash_profile
.  ~/.bashrc