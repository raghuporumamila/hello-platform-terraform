# 1. Create a specific identity for the Prod service (Least Privilege)
resource "google_service_account" "run_sa" {
  account_id   = "platform-runner-${var.env}"
  display_name = "Cloud Run Executor for ${var.env}"
}

resource "google_cloud_run_v2_service" "platform_service" {
  name                = var.service_name
  location            = var.region
  deletion_protection = var.deletion_protection

  # This restricts direct access to the .run.app URL
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

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

# 1. Create the Serverless NEG for Cloud Run
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "${var.service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.platform_service.name
  }
}

# 2. Create the Global Backend Service
resource "google_compute_backend_service" "default" {
  name                  = "${var.service_name}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# 3. URL Map to route incoming requests to the backend
resource "google_compute_url_map" "default" {
  name            = "${var.service_name}-url-map"
  default_service = google_compute_backend_service.default.id
}

# 4. Target HTTP Proxy (For HTTPS, you would use google_compute_target_https_proxy)
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.service_name}-http-proxy"
  url_map = google_compute_url_map.default.id
}

# 5. Global Forwarding Rule (The Public IP)
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.service_name}-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

