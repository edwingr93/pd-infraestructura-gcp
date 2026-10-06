output "state_bucket_name" {
  description = "Name to use in the platform backend configuration."
  value       = google_storage_bucket.terraform_state.name
}
