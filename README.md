# NHA-4-147 — DEPI Comprehensive DevOps Project

A full end-to-end DevOps pipeline for a **MERN stack e-commerce application**, covering infrastructure provisioning, configuration management, CI, GitOps-based CD with **Argo CD**, and observability — built as the DEPI Comprehensive Project.

The project takes the app from source code to a running, self-healing, GitOps-managed deployment on Kubernetes:

```
Terraform  →  Ansible  →  Jenkins CI  →  Git (manifests/Helm)  →  Argo CD (CD)  →  Kubernetes  →  Monitoring
```

## Architecture

![Architecture Diagram](./architecture_depi.drawio%20%281%29.png)

**Flow of the system:**

1. **Terraform** provisions the AWS network and compute layer (VPC, subnets, route tables, security groups, EC2 instances) that host the Kubernetes cluster nodes.
2. **Ansible** configures those nodes end-to-end: container runtime, Kubernetes control plane/workers, storage, and the supporting tool stack (Jenkins, SonarQube, Prometheus/Grafana/Loki, and Argo CD itself).
3. **Jenkins** runs CI for the `backend` and `frontend` services: checkout → SonarQube static analysis → Docker image build → Trivy scan → image push to the registry.
4. Jenkins updates the Kubernetes manifests / Helm values with the new image tag and pushes to Git — the single source of truth.
5. **Argo CD** continuously watches the Git repo and reconciles the live cluster state to match it (GitOps). It manages the MongoDB, backend, and frontend workloads, including a `PostSync` hook Job that initializes the MongoDB replica set only after the database StatefulSet is healthy.
6. **Prometheus, Grafana, and Loki/Promtail** provide metrics, dashboards, and log aggregation for the running cluster and workloads.

## Repository Structure

```text
NHA-4-147/
├── backend/                         # Node.js/Express API (MongoDB-backed)
│   ├── Dockerfile
│   └── Jenkinsfile                  # CI: Sonar scan → build → Trivy scan → push image
├── frontend/                        # React client
│   ├── Dockerfile
│   └── Jenkinsfile                  # Same CI pattern as backend
├── docker-compose.yml               # Local dev stack (backend + frontend + mongodb)
├── k8s/
│   ├── namespaces.yaml              # back-proj-ns / front-proj-ns / mongodb-proj-ns
│   ├── sealed-secrets.pem           # Public cert for sealing secrets before committing them
│   └── k8s/
│       ├── back/                    # Backend Deployment, Service, HPA, Secret
│       ├── front/                   # Frontend Deployment, Service, HPA
│       └── mongo/                   # MongoDB StatefulSet/Service, init & Argo CD PostSync seed Job
├── Helm/
│   ├── README.md                    # Helm-specific documentation
│   └── mern-ecommerce/              # Umbrella chart — Argo CD deploys this
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── templates/               # mongo-rs-init Job, helpers
│       └── charts/
│           ├── backend/
│           ├── frontend/
│           └── mongodb/
├── Ansible/proj-with-roles/         # Infrastructure & platform configuration
│   ├── inventory/                   # Dynamic AWS EC2 inventory
│   ├── k8s-cluster-setup.yaml       # Entry playbook
│   └── roles/
│       ├── k8s-preconfig/           # OS-level prep for all nodes
│       ├── k8s-containerd-docker/   # Container runtime
│       ├── k8s-packges/             # kubeadm/kubelet/kubectl install
│       ├── k8s-control-plane/       # Control plane init
│       ├── k8s-workers/             # Worker join
│       ├── k8s-storage/             # Cluster storage
│       ├── k8s-verification/        # Post-install cluster checks
│       ├── sonar/                   # SonarQube + PostgreSQL
│       ├── jenkins_k8s/             # Jenkins deployed via Helm on Kubernetes
│       ├── helm-argocd/             # Installs Helm + Argo CD on the cluster
│       └── prom-stack/              # Prometheus, Grafana, Loki, Promtail
└── terraform-aws-infrastructure/    # AWS infra (VPC, subnets, SGs, EC2, IGW, route tables)
    └── modules/
```

## Tech Stack

| Layer | Tools |
|---|---|
| Application | MERN (MongoDB, Express, React, Node.js) |
| Infrastructure as Code | Terraform (AWS) |
| Configuration Management | Ansible (roles-based) |
| Containers | Docker, containerd |
| Orchestration | Kubernetes (kubeadm, self-managed cluster) |
| Packaging | Helm (umbrella chart + subcharts) |
| CI | Jenkins (Kubernetes-agent pipelines) |
| Code Quality / Security | SonarQube, Trivy |
| CD / GitOps | **Argo CD** |
| Observability | Prometheus, Grafana, Loki, Promtail |
| Secrets | Sealed Secrets |

## Argo CD — GitOps Deployment

Argo CD is the deployment engine for this project: Git is the source of truth, and Argo CD continuously syncs the cluster to match it.

**Installation** (handled by the `helm-argocd` Ansible role):

- Installs Helm on the control node.
- Creates the `argocd` namespace and applies the official Argo CD install manifests.
- Waits for `argocd-server` to roll out, then patches its Service to `NodePort` (`30180`) for external access.
- Retrieves the initial admin password from the `argocd-initial-admin-secret` secret and prints the access URL, username, and password.

**Access:**

```
URL:      http://<node-ip>:30180
Username: admin
Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**What Argo CD manages:**

- The `Helm/mern-ecommerce` umbrella chart (backend, frontend, MongoDB subcharts).
- The MongoDB replica-set seed Job in `k8s/k8s/mongo/seed-job.yaml`, annotated as an Argo CD `PostSync` hook (`hook-delete-policy: HookSucceeded`) so it only runs — and only once — after MongoDB is synced and healthy, then cleans itself up.

**Sync flow:** Jenkins pushes a new image tag to Git → Argo CD detects the diff → syncs the affected Kubernetes objects → runs any pending hooks → app reflects the new version, with drift between Git and the live cluster continuously auto-corrected.

## CI Pipeline (Jenkins)

Each service (`backend`, `frontend`) has its own `Jenkinsfile`, using dynamic Kubernetes agent pods with `node`, `docker`, `sonar-scanner`, and `trivy` containers:

1. Checkout source from Git.
2. Static analysis via SonarQube (`sonar.projectKey=depi-test-project`).
3. Build the Docker image, tagged `v${BUILD_NUMBER}`.
4. Vulnerability scan with Trivy.
5. Push the image to the container registry.
6. Update the Kubernetes/Helm manifests with the new tag and push to Git for Argo CD to pick up.

## Helm Chart

The `Helm/mern-ecommerce` umbrella chart packages the full application (see [`Helm/README.md`](./Helm/README.md) for full details):

- **Parent chart** — centralizes namespaces, NodePorts, and global values.
- **`backend` subchart** — API Deployment/Service, exposed via NodePort.
- **`frontend` subchart** — React client Deployment/Service, exposed via NodePort, wired to the backend URL through values.
- **`mongodb` subchart** — StatefulSet with persistent storage, `ClusterIP` service, and replica-set initialization.

```bash
cd Helm/mern-ecommerce
helm dependency update
helm install mern-ecommerce .
```

In the GitOps flow, this install/upgrade is performed by Argo CD rather than run manually.

## Infrastructure & Configuration (Terraform + Ansible)

**Terraform** (`terraform-aws-infrastructure/`) provisions the AWS foundation: VPC, subnets, route tables, an internet gateway, security groups, and EC2 instances for the Kubernetes nodes.

**Ansible** (`Ansible/proj-with-roles/`) then configures those nodes using a dynamic AWS EC2 inventory and a roles-based playbook, `k8s-cluster-setup.yaml`, covering:

- OS prep, container runtime, and Kubernetes packages on every node
- Control plane initialization and worker join
- Cluster storage and post-install verification
- SonarQube + PostgreSQL for code quality
- Jenkins on Kubernetes via Helm
- **Argo CD** installation and NodePort exposure
- Prometheus, Grafana, Loki, and Promtail for monitoring/logging

## Monitoring

Deployed via the `prom-stack` Ansible role (kube-prometheus-stack + loki-stack Helm charts) into the `monitoring` namespace:

| Component | NodePort |
|---|---|
| Prometheus | `30090` |
| Grafana | `30300` |
| Alertmanager | `30093` |
| Loki | `30100` |

Grafana default credentials: `admin` / `admin123` (change before any non-local use).

## Local Development

For quick local iteration without Kubernetes, use Docker Compose:

```bash
docker compose up --build
```

This runs the backend (`:8000`), frontend (`:3000`), and a local MongoDB instance, wired together via `docker-compose.yml`. Required environment variables (`MONGO_URI`, `SECRET_KEY`, `ORIGIN`, `EMAIL`, `PASSWORD`, `REACT_APP_BASE_URL`, `MONGO_INITDB_*`, etc.) should be supplied via a `.env` file.

## Deployment Flow Summary

1. Terraform provisions AWS networking and EC2 instances.
2. Ansible bootstraps the Kubernetes cluster and installs Jenkins, SonarQube, Argo CD, and the monitoring stack.
3. Developers push code → Jenkins builds, scans, and publishes container images.
4. Manifests/Helm values are updated in Git with the new image tags.
5. Argo CD detects the change and syncs the cluster: namespaces → MongoDB (+ PostSync replica-set init) → backend → frontend.
6. Prometheus/Grafana/Loki provide ongoing visibility into cluster and application health.

## Secrets

Secrets committed to this repository (e.g. database credentials) are sealed with **Sealed Secrets** using the public certificate at `k8s/sealed-secrets.pem`, so only the controller running in the target cluster can decrypt them.

## Maintainer

Abdulrahman Gomaa Hassan — abdulrahman.gomaa.h05@gmail.com
