resource "google_artifact_registry_repository" "tramites" {
  project       = var.project_id
  location      = var.region
  repository_id = "tramites"
  description   = "Container images for the tramites API."
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "github_writer" {
  project    = var.project_id
  location   = google_artifact_registry_repository.tramites.location
  repository = google_artifact_registry_repository.tramites.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.github_actions_service_account}"
}
