   function cleanup_eks-tool-set.sh() {
      aws kms delete-alias --alias-name alias/eksworkshop
   }
   
   function cleanup_eks-cluster.sh() {
       eksctl delete cluster --region=us-west-2 --name=eksworkshop-eksctl
   }