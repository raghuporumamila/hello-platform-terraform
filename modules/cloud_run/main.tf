resource "google_cloud_run_v2_service" "platform_service" {
  name     = "${var.env}-platform-service"
  location = var.region
  deletion_protection = var.deletion_protection

  template {
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
    # Least Privilege: Application identity is scoped
    service_account = var.service_account_email
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count    = var.is_public ? 1 : 0
  location = google_cloud_run_v2_service.platform_service.location
  name     = google_cloud_run_v2_service.platform_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}