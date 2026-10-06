variable "project_id" {
  description = "GCP project that owns the Terraform state bucket."
  type        = string
  default     = "pd-ed-gar-2026"
}

variable "region" {
  description = "Region used for the Terraform state bucket."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
  default     = "pd-ed-gar-2026-tfstate"
}
