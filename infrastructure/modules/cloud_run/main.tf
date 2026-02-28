resource "google_cloud_run_service" "this" {
    name = var.service_name
    project = var.project_id
    location = var.region
    template {
        spec {
          service_account_name = var.service_account_email
          containers {
            image = var.image
            dynamic "env" {
                for_each = var.env_vars
                content {
                  name  = env.key
                  value = env.value
                }
            }
            dynamic "env" {
                for_each = var.secrets
                content {
                  name = env.key
                  value_from {
                    secret_key_ref {
                      name = env.value
                      key  = "latest"
                    }
                  }
                }
            }
          }
        }
        metadata {
          annotations = {
            "run.googleapis.com/cloudsql-instances" = var.cloud_sql_instance_connection_name
            "run.googleapis.com/vpc-access-egress"  = "private-range-only"
            "run.googleapis.com/network-interfaces" = jsonencode(
              [
                {
                  network    = var.vpc_network_id
                  subnetwork = var.subnet_id
                }
              ]
            )
          }
        }
    }
    traffic {
      percent = 100
      latest_revision = true
    }
    lifecycle {
      ignore_changes = [ traffic, ]
    }
    metadata {
      annotations = {
        "run.googleapis.com/ingress" = var.ingress
      }
    }
    # depends_on = [
    #   var.secret_version_dependencies,
    #   var.iam_dependencies
    # ]
}

resource "google_cloud_run_service_iam_member" "this" {
  for_each = toset(var.invokers)

  location = var.region
  project = var.project_id
  service = google_cloud_run_service.this.name
  role = "roles/run.invoker"
  member = each.value
}