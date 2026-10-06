output "repository_url" {
  value = "${google_artifact_registry_repository.tramites.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.tramites.repository_id}"
}

output "location" {
  value = google_artifact_registry_repository.tramites.location
}

output "repository_name" {
  value = google_artifact_registry_repository.tramites.name
}
