resource "google_cloud_run_v2_service" "tramites" {
  project             = var.project_id
  name                = "tramites-api"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  lifecycle {
    # The app pipeline owns the deployed image; Terraform owns the infrastructure.
    ignore_changes = [client, client_version, template[0].containers[0].image]
  }

  template {
    service_account = var.runtime_service_account_email

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = var.image_uri

      ports {
        container_port = 8080
      }

      env {
        name = "API_KEY"
        value_source {
          secret_key_ref {
            secret  = var.secret_id
            version = "latest"
          }
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  project  = var.project_id
  location = google_cloud_run_v2_service.tramites.location
  name     = google_cloud_run_v2_service.tramites.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
