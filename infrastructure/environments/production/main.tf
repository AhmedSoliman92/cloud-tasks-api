resource "google_project_service" "gcp_services" {
    for_each = toset(var.gcp_services_list)
    project  = "${var.project_id}-prod"
    service  = each.key

    disable_on_destroy = false
  }

resource "time_sleep" "wait_minute" {
    depends_on = [ google_project_service.gcp_services ]
    create_duration = "60s"
}

module "vpc" {
    source       = "../../modules/vpc"
    
    environment  = "prod"
    project_id   = "${var.project_id}-prod"
    region       = var.region
    network_name = "cloud-task-api-vpc-prod"
    subnet_name  = "cloud-task-api-subnet-prod"
    subnet_cidr  = "10.0.0.0/24"

    depends_on = [ time_sleep.wait_minute ]
}

module "service_account" {
    source       = "../../modules/iam"
    
    project_id   =  "${var.project_id}-prod"
    account_id   = "cloud-task-api-service-prod"
    display_name = "Cloud Task API Service Account"
    environment = "prod"

    depends_on = [ time_sleep.wait_minute ]
}

module "secrets" {
    source      = "../../modules/secrets"
    
    project_id  = "${var.project_id}-prod"
    secret_id   = "db-password-prod"
    secret_data = var.password

    depends_on = [ time_sleep.wait_minute ]
}

# module "artifact_registry" {
#     source        = "../../modules/artifact_registry"
    
#     project_id    = "${var.project_id}-prod"
#     environment   = "prod"
#     region        = var.region
#     repository_id = "cloud-task-api-prod"

#     depends_on = [ module.vpc]
# }

module "cloud_sql" {
    source = "../../modules/cloud_sql"
    
    project_id          = "${var.project_id}-prod"
    region              = var.region
    database_name       = "task-db-prod"
    deletion_protection = false
    instance_name       = "task-instance-prod"
    vpc_network_id      = module.vpc.network_id
    username            = var.username
    password            = var.password

    depends_on = [ time_sleep.wait_minute ]
}

module "cloud_run" {
    source = "../../modules/cloud_run"

    project_id                         = "${var.project_id}-prod"
    region                             = var.region
    service_name                       = "cloud-task-api-prod"
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
      ENV     = "prod"
    }
    secrets                            = {
        DB_PASS = "db-password-prod"
    }

    depends_on = [ module.secrets, module.service_account ]
}

module "loadbalancer" {
    source = "../../modules/loadbalancer"

    project_id = "${var.project_id}-prod"
    region = var.region
    prefix_name = "cloud-task-api-lb-prod"
    cloud_run_service_name = module.cloud_run.service_name

    depends_on = [ time_sleep.wait_minute ]
}