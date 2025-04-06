# artisight-project
Sullivan's submission for Artisight's "Cloud Team Technical Project"

Greetings Chris and Adam! This repo provides a fully automated GitOps deployment of [Servas](https://hub.docker.com/r/beromir/servas) — a self-hosted Laravel-based link manager — using Rancher [Fleet](https://fleet.rancher.io/).

## ✨ Highlights
- GitOps workflow using **Fleet**
- Helm-deployed Servas app + MariaDB
- Exposed through **NGINX Ingress** (also managed via Fleet)
- Fully local setup using Kubernetes (Kind, Docker Desktop, etc.)
- One-command deployment script

---

## 📦 Repositories Used

This repo orchestrates the deployment of two Git-managed Helm bundles:

| Component          | Repository |
|-------------------|------------|
| 🚀 App (Servas)    | [pakdarmo/servas-bundle](https://github.com/pakdarmo/servas-bundle) |
| 🌐 Ingress Controller | [pakdarmo/ingress-controller](https://github.com/pakdarmo/ingress-controller) |

---

## 🚀 Quickstart (One Command)

Make sure you have a running Kubernetes cluster, then:

```bash
./deploy-servas.sh


