echo "------------------------------------------------------"

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
aws eks --region $AWS_REGION update-kubeconfig --name eksworkshop-eksctl

kubectl create namespace metrics
helm install metrics-server \
    stable/metrics-server \
    --version 2.10.0 \
    --namespace metrics

kubectl get apiservice v1beta1.metrics.k8s.io -o yaml

helm install kube-ops-view \
stable/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True


helm list

kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'

echo "Installed Metrics server and kube ops view"
