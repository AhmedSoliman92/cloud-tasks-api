resource "google_project_service" "artifact_registry_api" {
    service            = "artifact_registry.googleapis.com"
    disable_on_destroy = false
}

resource "google_artifact_registry_repository" "this" {
    project       = var.project_id
    location      = var.region
    repository_id = var.repository_id
    description   = "artifactory to save docker image of the task-api project"
    format        = "DOCKER"

    depends_on = [ google_project_service.artifact_registry_api ]
}
