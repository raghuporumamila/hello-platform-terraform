variable "env" { type = string }
variable "project_id" { type = string }
variable "region" { type = string }
variable "container_image" { type = string }
variable "commit_sha" { type = string }
variable "service_account_email" { type = string }
variable "is_public" {
  type    = bool
  default = false
}