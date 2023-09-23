rm -vf ${HOME}/.aws/credentials

aws sts get-caller-identity

eksctl version

export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop --query KeyMetadata.Arn --output text)

echo "creating eks cluster in region ${AWS_REGION} with key ${MASTER_ARN} in AZs ${AZS[0]} ${AZS[1]} ${AZS[2]}"

export CLUSTER_VPC_ID=($(aws ec2 describe-vpcs --region $AWS_REGION  --filters Name="tag:Name",Values="eksctl-eksworkshop-VPC" | jq -r '.Vpcs[].VpcId'))
PUBLIC_SUBNETS[0]="$(aws ec2 describe-subnets --region $AWS_REGION  --filters Name=\"vpc-id\",Values=${CLUSTER_VPC_ID} Name=\"availability-zone\",Values=${AZS[0]} Name=\"tag:platform:visibility\",Values=\"public\" | jq -r '.Subnets[] | .SubnetId')"
PUBLIC_SUBNETS[1]="$(aws ec2 describe-subnets --region $AWS_REGION  --filters Name=\"vpc-id\",Values=${CLUSTER_VPC_ID} Name=\"availability-zone\",Values=${AZS[1]} Name=\"tag:platform:visibility\",Values=\"public\" | jq -r '.Subnets[] | .SubnetId')"
PUBLIC_SUBNETS[2]="$(aws ec2 describe-subnets --region $AWS_REGION  --filters Name=\"vpc-id\",Values=${CLUSTER_VPC_ID} Name=\"availability-zone\",Values=${AZS[2]} Name=\"tag:platform:visibility\",Values=\"public\" | jq -r '.Subnets[] | .SubnetId')"


PRIVATE_SUBNETS[0]="$(aws ec2 describe-subnets --region $AWS_REGION  --filters Name=\"vpc-id\",Values=${CLUSTER_VPC_ID} Name=\"availability-zone\",Values=${AZS[0]} Name=\"tag:platform:visibility\",Values=\"private\" | jq -r '.Subnets[] | .SubnetId')"
PRIVATE_SUBNETS[1]="$(aws ec2 describe-subnets --region $AWS_REGION  --filters Name=\"vpc-id\",Values=${CLUSTER_VPC_ID} Name=\"availability-zone\",Values=${AZS[1]} Name=\"tag:platform:visibility\",Values=\"private\" | jq -r '.Subnets[] | .SubnetId')"
PRIVATE_SUBNETS[2]="$(aws ec2 describe-subnets --region $AWS_REGION  --filters Name=\"vpc-id\",Values=${CLUSTER_VPC_ID} Name=\"availability-zone\",Values=${AZS[2]} Name=\"tag:platform:visibility\",Values=\"private\" | jq -r '.Subnets[] | .SubnetId')"

echo "Identified Cluster VPC ${CLUSTER_VPC_ID} and subnets ${PUBLIC_SUBNETS[0]}, ${PUBLIC_SUBNETS[1]}, ${PUBLIC_SUBNETS[2]}, ${PRIVATE_SUBNETS[0]}, ${PRIVATE_SUBNETS[1]}, ${PRIVATE_SUBNETS[2]}"

aws ec2 create-tags --resources ${PUBLIC_SUBNETS[0]} --tags Key=kubernetes.io/cluster/eksworkshop-eksctl,Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=eksworkshop-eksctl
aws ec2 create-tags --resources ${PUBLIC_SUBNETS[1]} --tags Key=kubernetes.io/cluster/eksworkshop-eksctl,Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=eksworkshop-eksctl
aws ec2 create-tags --resources ${PUBLIC_SUBNETS[2]} --tags Key=kubernetes.io/cluster/eksworkshop-eksctl,Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=eksworkshop-eksctl

aws ec2 create-tags --resources ${PRIVATE_SUBNETS[0]} --tags Key=kubernetes.io/cluster/eksworkshop-eksctl,Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=eksworkshop-eksctl
aws ec2 create-tags --resources ${PRIVATE_SUBNETS[1]} --tags Key=kubernetes.io/cluster/eksworkshop-eksctl,Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=eksworkshop-eksctl
aws ec2 create-tags --resources ${PRIVATE_SUBNETS[2]} --tags Key=kubernetes.io/cluster/eksworkshop-eksctl,Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=eksworkshop-eksctl

echo "Completed adding EKS tags to be make subnets compliant"

cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.24"

vpc:
  id: ${CLUSTER_VPC_ID}
  subnets:
    public:
      ${AZS[0]}:
          id: ${PUBLIC_SUBNETS[0]}
      ${AZS[1]}:
          id: ${PUBLIC_SUBNETS[1]}
      ${AZS[2]}:
          id: ${PUBLIC_SUBNETS[2]}
    private:
      ${AZS[0]}:
          id: ${PRIVATE_SUBNETS[0]}
      ${AZS[1]}:
          id: ${PRIVATE_SUBNETS[1]}
      ${AZS[2]}:
          id: ${PRIVATE_SUBNETS[2]}
          
managedNodeGroups:
- name: nodegroup
  minSize: 2
  maxSize: 3
  desiredCapacity: 3
  instanceType: m5.large
  #volumeSize: 20
  privateNetworking: true
  ssh:
    enableSsm: true
  labels: {role: workshop}
  tags:
    nodegroup-role: workshop

# To enable all of the control plane logs, uncomment below:
# cloudWatch:
#  clusterLogging:
#    enableTypes: ["*"]

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF

eksctl create cluster -f eksworkshop.yaml

aws eks --region $AWS_REGION update-kubeconfig --name eksworkshop-eksctl

kubectl get nodes

STACK_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a /home/ec2-user/.bash_profile

echo "Setup eks cluster"

echo "------------------------------------------------------"

rolearn=$(aws iam get-role --role-name WSParticipantRole --query Role.Arn --output text)

eksctl create iamidentitymapping --cluster eksworkshop-eksctl --arn ${rolearn} --group system:masters --username admin

echo "Added console credentials for console access"

echo "------------------------------------------------------"
echo "aws eks update-kubeconfig --name eksworkshop-eksctl --region ${AWS_REGION}" | tee -a /home/ec2-user/.bash_profile
echo "export LAB_CLUSTER_ID=eksworkshop-eksctl" | tee -a /home/ec2-user/.bash_profile

echo "Completed cluster setup"

echo "------------------------------------------------------"

echo "Install AWS Load Balancer Controller"

export LAB_CLUSTER_ID=eksworkshop-eksctl

eksctl utils associate-iam-oidc-provider --region ${AWS_REGION} --cluster ${LAB_CLUSTER_ID} --approve

curl -o iam-policy.json https://raw.githubusercontent.com/aws-containers/eks-app-mesh-polyglot-demo/master/workshop/aws_lbc_iam_policy.json

aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json

eksctl create iamserviceaccount --cluster=${LAB_CLUSTER_ID} --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --region ${AWS_REGION} --approve

curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=${LAB_CLUSTER_ID} --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

echo "Completed AWS Load Balancer Controller Installation"

echo "------------------------------------------------------"
