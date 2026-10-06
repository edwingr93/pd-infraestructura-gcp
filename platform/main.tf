provider "google" {
  project = var.project_id
  region  = var.region

  user_project_override = true
  billing_project       = var.project_id
}

data "google_project" "current" {
  project_id = var.project_id
}

module "apis" {
  source     = "./modules/apis"
  project_id = var.project_id
}

module "identities" {
  source            = "./modules/identities"
  project_id        = var.project_id
  github_repository = var.github_repository
  infra_repository  = var.infra_repository

  depends_on = [module.apis]
}

module "artifact_registry" {
  source                         = "./modules/artifact_registry"
  project_id                     = var.project_id
  region                         = var.region
  github_actions_service_account = module.identities.github_actions_service_account

  depends_on = [module.apis]
}

module "secret_manager" {
  source                        = "./modules/secret_manager"
  project_id                    = var.project_id
  runtime_service_account_email = module.identities.runtime_service_account_email

  depends_on = [module.apis]
}

module "cloud_run" {
  source                        = "./modules/cloud_run"
  project_id                    = var.project_id
  region                        = var.region
  image_uri                     = var.image_uri
  runtime_service_account_email = module.identities.runtime_service_account_email
  secret_id                     = module.secret_manager.secret_id

  depends_on = [module.apis, module.secret_manager]
}

module "github_deploy_permissions" {
  source                         = "./modules/github_deploy_permissions"
  project_id                     = var.project_id
  github_actions_service_account = module.identities.github_actions_service_account
  runtime_service_account_name   = module.identities.runtime_service_account_name
}

module "budget" {
  source             = "./modules/budget"
  billing_account_id = var.billing_account_id
  budget_amount_usd  = var.budget_amount_usd
  project_number     = data.google_project.current.number

  depends_on = [module.apis]
}

module "drift_detection" {
  source                    = "./modules/drift_detection"
  project_id                = var.project_id
  project_number            = data.google_project.current.number
  workload_identity_pool_id = module.identities.workload_identity_pool_id
  infra_repository          = var.infra_repository
  billing_account_id        = var.billing_account_id
  state_bucket              = var.state_bucket

  depends_on = [module.apis]
}
