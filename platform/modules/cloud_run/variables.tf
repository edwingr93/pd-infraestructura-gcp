variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "image_uri" {
  type        = string
  description = "Immutable Artifact Registry image URI tagged with a commit SHA or SemVer."
}

variable "runtime_service_account_email" {
  type = string
}

variable "secret_id" {
  type = string
}
