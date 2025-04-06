#!/bin/bash

set -euo pipefail

SERVAS_REPO="https://github.com/pakdarmo/servas-bundle.git"
INGRESS_REPO="https://github.com/pakdarmo/ingress-controller.git"
NAMESPACE="fleet-local"
FLEET_NS="cattle-fleet-system"

echo "Checking for existing Fleet installation..."

if ! kubectl get deployment -n ${FLEET_NS} fleet-agent >/dev/null 2>&1; then
  echo "Fleet not found in this cluster. Installing via Helm..."

  helm repo add fleet https://rancher.github.io/fleet-helm-charts/
  helm repo update

  helm upgrade --install fleet-crd fleet/fleet-crd \
    --namespace ${FLEET_NS} \
    --create-namespace \
    --wait

  helm upgrade --install fleet fleet/fleet \
    --namespace ${FLEET_NS} \
    --create-namespace \
    --wait
else
  echo "Fleet is already installed in this cluster. Skipping Helm installation."
fi

echo "Applying GitRepo for Servas..."
cat <<EOF | kubectl apply -f -
apiVersion: fleet.cattle.io/v1alpha1
kind: GitRepo
metadata:
  name: servas-repo
  namespace: ${NAMESPACE}
spec:
  repo: ${SERVAS_REPO}
  branch: main
  paths:
    - ./servas
EOF

echo "Applying GitRepo for Ingress controller..."
cat <<EOF | kubectl apply -f -
apiVersion: fleet.cattle.io/v1alpha1
kind: GitRepo
metadata:
  name: ingress-controller
  namespace: ${NAMESPACE}
spec:
  repo: ${INGRESS_REPO}
  branch: main
  paths:
    - .
EOF

echo "Waiting for bundles to deploy..."
kubectl get bundles -A
sleep 10

echo "Waiting for Ingress controller namespace to be created..."
until kubectl get ns ingress-nginx >/dev/null 2>&1; do
  sleep 2
done

echo "Waiting for Ingress controller service to become available..."
until kubectl get svc my-ingress-ingress-nginx-controller -n ingress-nginx >/dev/null 2>&1; do
  sleep 2
done

echo "Waiting for Servas pod to be ready..."
until kubectl get pods -l app=servas -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q "Running"; do
  sleep 2
done

echo "Waiting for MariaDB to be ready..."
until kubectl get pods -l app.kubernetes.io/name=mariadb -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null | grep -q "true"; do
  sleep 3
done


echo "Running Laravel migrations..."
kubectl exec -it $(kubectl get pods -l app=servas -o jsonpath='{.items[0].metadata.name}') -- php artisan migrate --force


echo "Starting port-forward to NGINX Ingress controller on port 80..."
echo "Note: requires sudo to bind to port 80"
echo "Navigate to http://localhost in your browser to enjoy Servas"
sudo kubectl port-forward svc/my-ingress-ingress-nginx-controller -n ingress-nginx 80:80
