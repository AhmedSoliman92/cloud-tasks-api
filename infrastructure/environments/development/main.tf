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

module "cloud_sql" {
    source = "../../modules/cloud_sql"
    
    project_id          = "${var.project_id}-dev"
    region              = var.region
    database_name       = "task-db-dev"
    deletion_protection = false
    instance_name       = "task-instance-dev"
    vpc_network_id      = module.vpc.network_id
    username            = "soli"
    password            = var.password

    depends_on = [ time_sleep.wait_minute ]
}

module "cloud_run" {
    source = "../../modules/cloud_run"

    project_id                         = "${var.project_id}-dev"
    region                             = var.region
    service_name                       = "cloud-task-api-dev"
    image                              = var.image
    service_account_email              = module.service_account.email
    cloud_sql_instance_connection_name = module.cloud_sql.connection_name
    # secret_version_dependencies        = [module.secrets.id]
    # iam_dependencies                   = [ module.service_account.secret_accessor_binding ]
    invokers                           = ["allUsers"]
    subnet_id                          = module.vpc.subnet_id
    vpc_network_id                     = module.vpc.network_id
    env_vars                           = {
      DB_HOST = "cloudsql/${module.cloud_sql.connection_name}"
      DB_NAME = module.cloud_sql.database_name
      DB_USER = module.cloud_sql.username
      ENV     = "dev"
    }
    secrets                            = {
        DB_PASS = "db-password-dev"
        FLASK_SECRET = "flask-secret-dev"
    }

    depends_on = [ module.secrets, module.service_account ]
}
