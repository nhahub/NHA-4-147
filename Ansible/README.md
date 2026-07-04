# Ansible Automation

This directory contains the Ansible automation used to provision and configure the Kubernetes environment for this project.

The automation is intentionally presented in two styles:

- `proj-in-one-yaml-file`: a single-playbook approach for end-to-end setup
- `proj-with-roles`: a role-based approach for cleaner maintenance and reuse

Both approaches show how infrastructure can be treated as code while still keeping the workflow understandable and auditable.

## What It Does

- Configures Linux prerequisites for Kubernetes
- Disables swap and adjusts system settings required by the cluster
- Installs and configures `containerd`
- Installs Kubernetes packages such as `kubeadm`, `kubelet`, and `kubectl`
- Initializes the control plane
- Generates and reuses worker join commands
- Joins worker nodes to the cluster
- Verifies cluster health after bootstrap
- Prepares the cluster for Helm, Argo CD, and monitoring-related tooling

## Why This Approach Is Good

- Modular: each task group has a clear responsibility
- Reusable: roles can be reused across environments or future projects
- Readable: the playbook flow reflects the actual cluster lifecycle
- Safer: checks are built in to avoid repeating initialization steps
- Maintainable: role boundaries make updates easier to test

## Directory Structure

```text
Ansible/
├── proj-in-one-yaml-file/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── k8s-cluster-playbook.yaml
│   ├── kubernetes.repo
│   ├── required_modules.yaml
│   └── sysctl_k8s_conf
└── proj-with-roles/
    ├── ansible.cfg
    ├── inventory.ini
    ├── k8s-cluster-setup.yaml
    └── roles/
        ├── k8s-preconfig
        ├── k8s-containerd
        ├── k8s-packges
        ├── k8s-control-plane
        ├── k8s-workers
        ├── k8s-verification
        └── k8s-helm-argocd-monitoring_STACK
```

## Playbook Flow

### Single Playbook

The one-file playbook is useful for understanding the full setup sequence in one place:

1. Common Linux pre-configuration
2. Container runtime installation
3. Kubernetes package installation
4. Control plane initialization
5. Worker node join
6. Cluster verification

### Role-Based Playbook

The role-based version breaks the workflow into dedicated units:

- `k8s-preconfig`: baseline Linux and kernel tuning
- `k8s-containerd`: container runtime installation and configuration
- `k8s-packges`: Kubernetes package installation
- `k8s-control-plane`: control plane initialization
- `k8s-workers`: worker node joining
- `k8s-verification`: cluster checks and validation
- `k8s-helm-argocd-monitoring_STACK`: platform tooling setup

## Best Practices Followed

- Use of roles for separation of concerns
- Idempotent patterns such as `stat` checks before initialization
- Configuration through inventory and variables instead of hardcoding
- System-level tuning for Kubernetes networking and kernel modules
- Disabled swap, firewall, and restrictive SELinux settings where appropriate for the cluster
- Verification steps after provisioning to confirm the environment is healthy

## Prerequisites

- Ansible installed on the control machine
- SSH access to all target nodes
- Privilege escalation available on target machines
- A valid inventory file that matches your environment
- Supported Linux nodes prepared for Kubernetes installation

## Usage

### Role-based setup

From `Ansible/proj-with-roles`:

```bash
ansible-playbook -i inventory.ini k8s-cluster-setup.yaml
```

### Single-playbook setup

From `Ansible/proj-in-one-yaml-file`:

```bash
ansible-playbook -i inventory.ini k8s-cluster-playbook.yaml
```

## Notes

- Update `inventory.ini` before running any playbook.
- Review `required_modules.yaml` and role defaults if your environment differs.
- The playbooks are tailored for Kubernetes bootstrap workflows and may require adjustment for a different Linux distribution or Kubernetes version.
