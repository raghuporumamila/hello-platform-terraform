resource "google_service_account" "terraform_ci" {
  account_id   = "terraform-ci-deployer"
  project      = var.admin_project_id
  display_name = "CI/CD Terraform Executor"
}

# Assign roles/run.admin and roles/iam.serviceAccountUser
# to this account at the Project level for deployment permissions.