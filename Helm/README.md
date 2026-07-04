# Helm Charts

This directory contains the Helm packaging for the MERN ecommerce application.

The chart set packages the backend, frontend, and MongoDB layers into a reusable deployment model with environment-specific values and clearly separated templates.

## What It Includes

- A parent chart for the full application stack
- Subcharts for:
  - `frontend`
  - `backend`
  - `mongodb`
- Namespace and service templates for each component
- A MongoDB initialization job
- Helper templates for consistent naming and reuse

## Why This Approach Is Good

- Reusable: the same chart can be deployed into different environments by changing values
- Maintainable: subcharts isolate concerns for each service
- Declarative: the desired state lives in chart templates and values
- Consistent: helpers and shared values reduce duplication
- Safer: configuration is centralized instead of spread across ad hoc manifests

## Directory Structure

```text
Helm/
└── mern-ecommerce/
    ├── Chart.yaml
    ├── values.yaml
    ├── templates/
    │   ├── mongo-init-job.yaml
    │   └── _helpers.tpl
    └── charts/
        ├── backend/
        ├── frontend/
        └── mongodb/
```

## Chart Summary

### Parent Chart

The root `mern-ecommerce` chart is the entry point for deploying the full stack. It centralizes:

- NodePort settings
- namespace names
- global service values
- image and environment configuration

### Backend

- Deploys the API service
- Uses a dedicated namespace for clean separation
- Exposes the service through a `NodePort`
- Receives runtime settings through chart values

### Frontend

- Deploys the React client
- Uses a `NodePort` for external access
- Consumes the backend API URL through environment variables

### MongoDB

- Deploys the database layer
- Uses a `ClusterIP` service for internal-only access
- Includes persistent storage and initialization resources

## Best Practices Followed

- Configuration through `values.yaml` instead of hardcoding values
- Parent and subchart separation for a cleaner deployment boundary
- Namespace isolation for each component
- Explicit service ports and NodePorts for predictable exposure
- Template helpers for naming consistency
- A dedicated initialization job for database bootstrap logic
- Values-driven backend URL injection for the frontend

## Prerequisites

- Kubernetes cluster is running and reachable
- Helm v3 installed locally
- `kubectl` configured for the target cluster
- Container images are available in the configured registry
- The namespace values in `values.yaml` match your environment

## Installation

From `Helm/mern-ecommerce`:

```bash
helm dependency update
helm install mern-ecommerce .
```

To upgrade an existing release:

```bash
helm upgrade mern-ecommerce .
```

To uninstall:

```bash
helm uninstall mern-ecommerce
```

## Configuration

Most environment-specific settings are controlled from `values.yaml`, including:

- image repositories and tags
- service types
- ports and NodePorts
- namespace names
- backend API URL used by the frontend

Before deployment, review the following carefully:

- `global.nodeIP`
- `global.back_nodeport`
- `global.front_nodeport`
- `frontend.env_url.value`
- namespace values for each subchart

## Operational Notes

- Update the image repository names if you publish to a different registry.
- Ensure the NodePort values do not conflict with other services in your cluster.
- If you change namespace names, keep them consistent across the parent chart and subcharts.
- Review the MongoDB initialization job if your authentication or seeding flow changes.
- Run `helm lint` before applying changes to catch template issues early.

## Deployment Flow

1. Kubernetes namespaces are created.
2. MongoDB is deployed and initialized.
3. Backend services are deployed and connected to the database.
4. Frontend services are deployed and configured to reach the backend.

## Maintenance

- Use `helm lint` before deploying chart changes.
- Keep chart values environment-specific and avoid hardcoding runtime details in templates.
- Treat the chart as the source of truth for application deployment settings.
