resource "google_service_account" "this" {
    account_id   = var.account_id
    display_name = var.display_name
    project      = var.project_id
}

locals {
  app_roles = [
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.reader",
    "roles/logging.logWriter"
  ]
}

resource "google_project_iam_member" "app_permissions" {
    for_each = toset(local.app_roles)
    project = var.project_id
    role = each.key
    member = "serviceAccount:${google_service_account.this.email}"
}

