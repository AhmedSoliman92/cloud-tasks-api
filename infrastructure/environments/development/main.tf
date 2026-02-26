resource "google_project_service" "gcp_services" {
    for_each = toset(var.gcp_services_list)
    project  = "${var.project_id}-dev"
    service  = each.key

    disable_on_destroy = false
  }

resource "time_sleep" "wait_minute" {
    depends_on = [ google_project_service.gcp_services ]
    create_duration = "60s"
}

module "vpc" {
    source       = "../../modules/vpc"
    
    environment  = "dev"
    project_id   = "${var.project_id}-dev"
    region       = var.region
    network_name = "cloud-task-api-vpc-dev"
    subnet_name  = "cloud-task-api-subnet-dev"
    subnet_cidr  = "10.0.0.0/24"

    depends_on = [ time_sleep.wait_minute ]
}

module "service_account" {
    source       = "../../modules/iam"
    
    project_id   =  "${var.project_id}-dev"
    account_id   = "cloud-task-api-service-dev"
    display_name = "Cloud Task API Service Account"

    depends_on = [ time_sleep.wait_minute ]
}

module "secrets" {
    source      = "../../modules/secrets"
    
    project_id  = "${var.project_id}-dev"
    secret_id   = "db-password-dev"
    secret_data = var.password

    depends_on = [ time_sleep.wait_minute ]
}

module "artifact_registry" {
    source        = "../../modules/artifact_registry"
    
    project_id    = "${var.project_id}-dev"
    environment   = "dev"
    region        = var.region
    repository_id = "cloud-task-api-dev"

    depends_on = [ module.vpc]
}
