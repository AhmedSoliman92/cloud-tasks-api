resource "random_id" "this" {
    byte_length = 4
}

resource "google_sql_database_instance" "this" {
    name                = "db-${var.instance_name}-${random_id.this.hex}"
    project             = var.project_id
    region              = var.region
    deletion_protection = var.deletion_protection
    database_version    = "POSTGRES_17"

    settings {
      tier = "db-f1-micro"
      edition = "ENTERPRISE"
      ip_configuration {
        ipv4_enabled = false
        private_network = var.vpc_network_id
      }
    }
}

resource "google_sql_database" "this" {
    name     = var.database_name
    instance = google_sql_database_instance.this.name
    project  = var.project_id
}

resource "google_sql_user" "this" {
    name    = var.username
    project = var.project_id
    instance = google_sql_database_instance.this.name
    password = var.password
}