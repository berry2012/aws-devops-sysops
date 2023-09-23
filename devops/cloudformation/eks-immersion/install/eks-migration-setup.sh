echo "Initialize cluster variables"
echo "------------------------------------------------------"

export CLUSTER=eksworkshop
export AWS_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_REGION=${AWS_ZONE::-1}
export AWS_DEFAULT_REGION=${AWS_REGION}
export ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac)
export SECURITY_GROUP=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/security-group-ids)
export SUBNET=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/subnet-id)
export VPC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/vpc-id)
export IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

printf "export CLUSTER=$CLUSTER\nexport ACCOUNT_ID=$ACCOUNT_ID\nexport AWS_REGION=$AWS_REGION\nexport AWS_DEFAULT_REGION=${AWS_REGION}\nexport AWS_ZONE=$AWS_ZONE\nexport INSTANCE_ID=$INSTANCE_ID\nexport MAC=$MAC\nexport SECURITY_GROUP=$SECURITY_GROUP\nexport SUBNET=$SUBNET\nexport VPC=$VPC\nexport IP=$IP" | tee -a /home/ec2-user/.bash_profile
#. ~/.bash_profile
echo "------------------------------------------------------"
echo "Install IAM Authenticator"

# install aws-iam-authenticator
sudo curl -sLO "https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator"
sudo install -o root -g root -m 0755 aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
sudo rm -f ./aws-iam-authenticator

echo "------------------------------------------------------"
echo "Install Kind tool set"

# install kind
sudo curl -sLo kind "https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64"
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
sudo rm -f ./kind

echo "------------------------------------------------------"
echo "Create eks cluster"

eksctl create cluster --name $CLUSTER --managed --enable-ssm

echo "------------------------------------------------------"
echo "Create kind cluster"

echo 'net.ipv4.conf.all.route_localnet = 1' | sudo tee /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf
sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
echo -e "\necho Adding iptable entries\n" | tee -a /home/ec2-user/.bash_profile
echo "sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679" | tee -a /home/ec2-user/.bash_profile
echo "sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679" | tee -a /home/ec2-user/.bash_profile

cat > kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.19.11@sha256:07db187ae84b4b7de440a73886f008cf903fcf5764ba8106a9fd5243d6f32729
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
  - containerPort: 30001
    hostPort: 30001
EOF

kind create cluster --config kind.yaml

kubectl config use-context "${INSTANCE_ID}@${CLUSTER}.${AWS_REGION}.eksctl.io"

ls -ltr

cp -r .kube /home/ec2-user/
chown ec2-user /home/ec2-user/.kube
chmod -R 755 /home/ec2-user/.kube

echo "kubectl config use-context \"${INSTANCE_ID}@${CLUSTER}.${AWS_REGION}.eksctl.io\""  | tee -a /home/ec2-user/.bash_profile

echo "------------------------------------------------------"