resource "google_service_account" "drift" {
  project      = var.project_id
  account_id   = "terraform-drift"
  display_name = "Terraform drift detection (read-only)"
}

resource "google_service_account_iam_member" "drift_wif" {
  service_account_id = google_service_account.drift.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository/${var.infra_repository}"
}

# Read-only roles needed for `terraform plan` to refresh every managed resource.
resource "google_project_iam_member" "drift_read" {
  for_each = toset([
    "roles/viewer",
    "roles/iam.securityReviewer",
    "roles/iam.workloadIdentityPoolViewer",
    "roles/serviceusage.serviceUsageConsumer",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.drift.email}"
}

resource "google_billing_account_iam_member" "drift_billing_viewer" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.viewer"
  member             = "serviceAccount:${google_service_account.drift.email}"
}

# Plan runs with -lock=false, so read access to the state is enough.
resource "google_storage_bucket_iam_member" "drift_state_reader" {
  bucket = var.state_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.drift.email}"
}

# `terraform init` always writes the lock object, even with -lock=false.
# Scope write access to lock files only; the state itself stays read-only.
resource "google_storage_bucket_iam_member" "drift_lock_writer" {
  bucket = var.state_bucket
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.drift.email}"

  condition {
    title      = "tflock-objects-only"
    expression = "resource.name.endsWith('.tflock')"
  }
}
