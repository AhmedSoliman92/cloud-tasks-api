output "email" {
    value = google_service_account.this.email  
}

output "secret_accessor_binding" {
    value = google_project_iam_member.app_permissions["roles/secretmanager.secretAccessor"].id
}