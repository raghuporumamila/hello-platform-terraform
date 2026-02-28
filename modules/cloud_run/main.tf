# 1. Create a specific identity for the Prod service (Least Privilege)
resource "google_service_account" "run_sa" {
  account_id   = "platform-runner-${var.env}"
  display_name = "Cloud Run Executor for ${var.env}"
}

resource "google_cloud_run_v2_service" "platform_service" {
  name     = "${var.env}-platform-service"
  location = var.region
  deletion_protection = var.deletion_protection

  template {
    service_account = google_service_account.run_sa.email
    containers {
      image = var.container_image
      ports {
        container_port = 8080
      }
      env {
        name  = "APP_COMMIT_SHA"
        value = var.commit_sha
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count    = var.is_public ? 1 : 0
  location = google_cloud_run_v2_service.platform_service.location
  name     = google_cloud_run_v2_service.platform_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

