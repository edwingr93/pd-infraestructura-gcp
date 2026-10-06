output "artifact_registry_repository" {
  description = "Artifact Registry repository URL."
  value       = module.artifact_registry.repository_url
}

output "cloud_run_url" {
  description = "Public URL of the tramites Cloud Run service."
  value       = module.cloud_run.uri
}

output "github_workload_identity_provider" {
  description = "Provider resource name to configure as GCP_WORKLOAD_IDENTITY_PROVIDER in GitHub."
  value       = module.identities.workload_identity_provider
}

output "github_service_account" {
  description = "Service account email to configure as GCP_SERVICE_ACCOUNT in GitHub."
  value       = module.identities.github_actions_service_account
}

output "drift_service_account" {
  description = "Service account email to configure as GCP_DRIFT_SERVICE_ACCOUNT in the infra repo."
  value       = module.drift_detection.service_account_email
}
