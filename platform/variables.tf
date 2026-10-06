variable "project_id" {
  description = "GCP project for the tramites platform."
  type        = string
  default     = "pd-ed-gar-2026"
}

variable "region" {
  description = "Region for Artifact Registry and Cloud Run."
  type        = string
  default     = "us-central1"
}

variable "billing_account_id" {
  description = "Billing account used to attach the required budget alert."
  type        = string
  default     = "01D773-172749-E4264B"
}

variable "github_repository" {
  description = "GitHub owner/repository allowed to authenticate through WIF."
  type        = string
  default     = "edwingr93/prueba-tecnica-tramites"
}

variable "image_uri" {
  description = "Immutable Artifact Registry image URI including a commit SHA or SemVer tag."
  type        = string
}

variable "budget_amount_usd" {
  description = "Monthly budget alert threshold in USD. This alerts but does not cap spending."
  type        = number
  default     = 10
}

variable "infra_repository" {
  description = "GitHub owner/repository of this Terraform code (runs drift detection)."
  type        = string
  default     = "edwingr93/pd-infraestructura-gcp"
}

variable "state_bucket" {
  description = "GCS bucket that stores the Terraform state."
  type        = string
  default     = "pd-ed-gar-2026-tfstate"
}
