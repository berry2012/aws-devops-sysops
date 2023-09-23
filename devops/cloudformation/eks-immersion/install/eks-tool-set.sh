echo "Install EKS toolset"
echo "------------------------------------------------------"

curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.20.4/2021-04-12/bin/linux/amd64/kubectl

chmod +x /usr/local/bin/kubectl

echo "Installed Kubectl and util tools"

echo "------------------------------------------------------"

echo "Update Go Version"
echo "------------------------------------------------------"

git clone https://github.com/udhos/update-golang
cd update-golang
sudo ./update-golang.sh >> /tmp/golanginstall.txt 2>&1

echo "Updated Go to 1.20"
echo "------------------------------------------------------"
cd ..

echo "Update AWS CLI and utilities"

sudo pip3 install --upgrade awscli && hash -r

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip 
#./aws/install
./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

export PATH=/usr/local/aws-cli/v2/2.5.8/bin/:$PATH
echo 'export PATH=/usr/local/aws-cli/v2/2.5.8/bin/:$PATH' | tee -a /home/ec2-user/.bash_profile

yum -y install jq gettext bash-completion moreutils

echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a /home/ec2-user/.bashrc && source /home/ec2-user/.bashrc

echo "------------------------------------------------------"

yum install -y nodejs npm --enablerepo=epel

npm install -g c9

for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done

/usr/local/bin/kubectl completion bash >>  /home/ec2-user/.bash_completion
echo ". /etc/profile.d/bash_completion.sh" |  tee -a  /home/ec2-user/.bash_profile
echo ". /home/ec2-user/.bash_completion" | tee -a  /home/ec2-user/.bash_profile
echo "curl -sS https://webinstall.dev/k9s | bash" | tee -a  /home/ec2-user/.bash_profile

git clone --depth 1 https://github.com/junegunn/fzf.git  /home/ec2-user/.fzf
echo "sudo /home/ec2-user/.fzf/install --all" | tee -a  /home/ec2-user/.bash_profile
curl https://raw.githubusercontent.com/blendle/kns/master/bin/kns -o /usr/local/bin/kns && sudo chmod +x $_
curl https://raw.githubusercontent.com/blendle/kns/master/bin/ktx -o /usr/local/bin/ktx && sudo chmod +x $_
echo "alias kgn='kubectl get nodes -L beta.kubernetes.io/arch -L eks.amazonaws.com/capacityType -L beta.kubernetes.io/instance-type -L eks.amazonaws.com/nodegroup -L topology.kubernetes.io/zone -L karpenter.sh/provisioner-name -L karpenter.sh/capacity-type'" | tee -a /home/ec2-user/.bashrc
#source /home/ec2-user/.bash_profile

echo "aws cloud9 update-environment  --environment-id ${CLOUD9_ID} --managed-credentials-action DISABLE > /dev/null 2>&1" |  tee -a /home/ec2-user/.bash_profile

echo "kgn" |  tee -a /home/ec2-user/.bash_profile

echo "Installed additional tools"

echo "------------------------------------------------------"

KEY_ALIAS_NM="alias/eksworkshop"
aws kms create-alias --alias-name $KEY_ALIAS_NM --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)

export MASTER_ARN=$(aws kms describe-key --key-id $KEY_ALIAS_NM --query KeyMetadata.Arn --output text)

echo "export MASTER_ARN=${MASTER_ARN}" | tee -a  /home/ec2-user/.bash_profile

echo "Setup master key complete"

echo "------------------------------------------------------"

curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.147.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin


echo "Downloaded and installed eksctl"

echo "------------------------------------------------------"

curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

helm version --short

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "helm repo add stable https://charts.helm.sh/stable" | tee -a /home/ec2-user/.bash_profile
echo "helm repo add stable https://charts.helm.sh/stable" | tee -a /home/ec2-user/.bash_profile

helm search repo stable

echo "Completed setup of Helm"

echo "------------------------------------------------------"

curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v1.3.0/ec2-instance-selector-`uname | tr '[:upper:]' '[:lower:]'`-amd64 && chmod +x ec2-instance-selector
sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version

echo "Installed EC2 instance selector"

echo "------------------------------------------------------"

git clone https://github.com/aws-containers/eks-app-mesh-polyglot-demo.git /home/ec2-user/environment/eks-app-mesh-polyglot-demo/
chown -R ec2-user /home/ec2-user/environment/eks-app-mesh-polyglot-demo/
echo "cd eks-app-mesh-polyglot-demo" | tee -a /home/ec2-user/.bash_profile

echo "Downloded app from Git repo"

echo "------------------------------------------------------"
