resource "google_project_iam_member" "github_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${var.github_actions_service_account}"
}

resource "google_service_account_iam_member" "github_can_deploy_as_runtime" {
  service_account_id = var.runtime_service_account_name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.github_actions_service_account}"
}
