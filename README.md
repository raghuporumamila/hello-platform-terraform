# Cloud Run Terraform Module

`modules/cloud_run`

## Overview

This Terraform module provisions a Google Cloud Run v2 service with least-privilege IAM configuration. It creates a dedicated service account per environment, deploys a containerised workload, and optionally exposes the service publicly.

## Architecture

The module creates the following Google Cloud resources:

- A dedicated **Google Service Account** scoped per environment (`platform-runner-<env>`)
- A **Cloud Run v2 Service** running the specified container image on port `8080`
- An optional **IAM binding** granting `allUsers` the `run.invoker` role (for public services)

## Usage

```hcl
module "cloud_run" {
  source = "./modules/cloud_run"

  env             = "prod"
  project_id      = "my-gcp-project"
  region          = "us-central1"
  service_name    = "my-platform-service"
  container_image = "gcr.io/my-project/my-app:latest"
  commit_sha      = "abc1234"
  is_public       = true
}
```

## Input Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `env` | `string` | required | Environment name (e.g. `prod`, `staging`). Appended to the service account name. |
| `project_id` | `string` | required | GCP project ID where resources will be deployed. |
| `region` | `string` | required | GCP region for the Cloud Run service (e.g. `us-central1`). |
| `service_name` | `string` | required | Name of the Cloud Run service. |
| `container_image` | `string` | required | Full container image URI to deploy (e.g. `gcr.io/project/app:tag`). |
| `commit_sha` | `string` | required | Git commit SHA injected as the `APP_COMMIT_SHA` environment variable. |
| `is_public` | `bool` | `false` | If `true`, grants `allUsers` the `run.invoker` role, making the service publicly accessible. |
| `deletion_protection` | `bool` | `true` | Enables deletion protection on the Cloud Run service to prevent accidental removal. |

## Outputs

| Output | Description |
|---|---|
| `service_url` | The HTTPS URL of the deployed Cloud Run service. |

## IAM & Security

### Service Account

Each environment gets a dedicated service account named `platform-runner-<env>`. This follows the principle of least privilege — the service account has no permissions beyond those explicitly granted.

### Public Access

When `is_public` is set to `true`, the module creates an IAM binding that allows any unauthenticated user to invoke the service (`roles/run.invoker` for `allUsers`). Leave this as `false` (the default) for internal or private services.

## Environment Variables

The following environment variable is automatically injected into the container at deploy time:

| Variable | Value |
|---|---|
| `APP_COMMIT_SHA` | The value of `var.commit_sha` — useful for tracing which build is running. |

## Requirements

- Terraform >= 1.0
- Google Cloud provider >= 4.0
- A GCP project with the Cloud Run API and IAM API enabled

## Module File Structure

```
modules/cloud_run/
  main.tf         # Service account, Cloud Run service, IAM binding
  variables.tf    # Input variable declarations
  output.tf       # Exported service URL
```
