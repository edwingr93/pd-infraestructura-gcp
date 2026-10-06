resource "google_secret_manager_secret" "api_key" {
  project   = var.project_id
  secret_id = "tramites-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "runtime_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.runtime_service_account_email}"
}
