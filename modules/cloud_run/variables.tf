variable "env" { type = string }
variable "region" { type = string }
variable "container_image" { type = string }
variable "commit_sha" { type = string }
variable "is_public" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  description = "Whether or not to protect the service from accidental deletion."
  type        = bool
  default     = true
}
