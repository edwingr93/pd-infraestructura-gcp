resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = "tramites-runtime"
  display_name = "Tramites Cloud Run runtime"
}

resource "google_service_account" "github_actions" {
  project      = var.project_id
  account_id   = "github-actions-tramites"
  display_name = "GitHub Actions deploy identity for tramites"
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "OIDC identities from the tramites GitHub repository."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "tramites"
  display_name                       = "Tramites GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository in ['${var.github_repository}', '${var.infra_repository}']"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account_iam_member" "github_wif" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_repository}"
}
