#!/bin/bash

set -euo pipefail

SERVAS_REPO="https://github.com/pakdarmo/servas-bundle.git"
INGRESS_REPO="https://github.com/pakdarmo/ingress-controller.git"
NAMESPACE="fleet-local"

echo "🚀 Deploying Servas via Fleet..."

# Step 1: Install Fleet CRDs and agent
echo "🔧 Installing Fleet..."
kubectl apply -f https://github.com/rancher/fleet/releases/latest/download/fleet-crd.yaml
kubectl apply -f https://github.com/rancher/fleet/releases/latest/download/fleet-agent.yaml

echo "⏳ Waiting for Fleet agent to be ready..."
kubectl wait --for=condition=available deployment fleet-agent -n ${NAMESPACE} --timeout=60s

# Step 2: Apply GitRepos for Servas and Ingress
echo "📦 Applying GitRepo for Servas..."
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

echo "📦 Applying GitRepo for Ingress controller..."
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

echo "⏳ Waiting for Fleet bundles to become active..."
sleep 10
kubectl get bundles -A

# Step 3: Port-forward to ingress controller (on port 80)
echo "🌐 Starting port-forward to NGINX Ingress controller on port 80..."
echo "🔒 Note: this requires sudo due to binding to port 80"
echo "🌍 Once running, open http://localhost in your browser"

sudo kubectl port-forward svc/my-ingress-ingress-nginx-controller -n ingress-nginx 80:80

