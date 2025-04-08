# artisight-project
Sullivan's submission for Artisight's "Cloud Team Technical Project"

Greetings Chris and Adam! This repo provides a fully automated GitOps deployment of [Servas](https://hub.docker.com/r/beromir/servas) — a self-hosted Laravel-based link manager — using Rancher [Fleet](https://fleet.rancher.io/).

## Overview
- GitOps workflow using **Fleet**
- Helm-deployed Servas app + MariaDB
- Exposed through **NGINX Ingress** (also managed via Fleet)
- Fully local setup using Kubernetes (Kind, Docker Desktop, etc.)
- One-command deployment script

---

## Repositories Used

This repo orchestrates the deployment of two Git-managed Helm bundles:

| Component          | Repository |
|-------------------|------------|
| App (Servas)    | [pakdarmo/servas-bundle](https://github.com/pakdarmo/servas-bundle) |
| Ingress Controller | [pakdarmo/ingress-controller](https://github.com/pakdarmo/ingress-controller) |

---

## Quickstart (One Command)

Make sure you have a running Kubernetes cluster, then:

```bash
./deploy-servas.sh
```
You may need to supply your password once this script is complete in order to allow the port-forwarding command to execute.
Once the script is done simply navigate to http://localhost in  your browser.

---

## Manual Deployment

1. Install Fleet
```
helm repo add fleet https://rancher.github.io/fleet-helm-charts/
helm upgrade --install fleet-crd fleet/fleet-crd --namespace "cattle-fleet-system" --create-namespace
helm upgrade --install fleet fleet/fleet --namespace "cattle-fleet-system" --create-namespace
helm repo update
```

2. Apply GitRepo for Servas
```
kubectl apply -f gitrepo-servas.yaml
```
3. Apply GitRepo for Ingress Controller
```
kubectl apply -f gitrepo-ingress.yaml
```
4. Confirm Fleet Bundles
```
kubectl get bundles -A
```
You should see something like this:
```
NAMESPACE     NAME                 BUNDLEDEPLOYMENTS-READY   STATUS
fleet-local   servas-repo          1/1                       Active
fleet-local   ingress-controller   1/1                       Active
```
5. Port-Forward to Access Servas
```
sudo kubectl port-forward svc/my-ingress-ingress-nginx-controller -n ingress-nginx 80:80
```
Then open:
http://localhost

---

## Cleanup

Remove GitRepo Resources
```
kubectl delete gitrepo servas-repo -n fleet-local
kubectl delete gitrepo ingress-controller -n fleet-local
```

