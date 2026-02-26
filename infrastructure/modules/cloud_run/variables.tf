variable "service_name" {
    type = string  
}

variable "region" {
    type = string  
}

variable "project_id" {
    type = string  
}

variable "service_account_email" {
    type = string
}

variable "image" {
    type = string  
}

variable "env_vars" {
    type = map(string)  
    default = {}
}

variable "secrets" {
    type = map(string)  
    default = {}
}

variable "cloud_sql_instance_connection_name" {
    type = string
}

variable "vpc_network_id" {
    type = string
}

variable "subnet_id" {
    type = string  
}

variable "ingress" {
    type = string
    default = "internal-and-cloud-load-balancing"  
}

# variable "secret_version_dependencies" {
#     type = any
#     default = []
# }

# variable "iam_dependencies" {
#     type = any
#     default = []  
# }

variable "invokers" {
    type = list(string)
    default = []
}

resource "google_cloud_run_service_iam_member" "invoker" {
  for_each = toset(var.invokers)

  location = var.region
  project  = var.project_id
  service  = google_cloud_run_service.this.name
  role     = "roles/run.invoker"
  member   = each.value
}