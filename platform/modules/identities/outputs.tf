output "runtime_service_account_email" {
  value = google_service_account.runtime.email
}

output "runtime_service_account_name" {
  value = google_service_account.runtime.name
}

output "github_actions_account_id" {
  value = google_service_account.github_actions.account_id
}

output "github_actions_service_account" {
  value = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}
output "workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.github.workload_identity_pool_id
}
