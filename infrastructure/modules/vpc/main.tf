resource "google_compute_network" "this" {
    name                            = var.network_name
    project                         = var.project_id
    auto_create_subnetworks         = false
    routing_mode                    = "REGIONAL"
    description                     = "VPC for cloud-task-api in development environment"
    delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "this" {
    name                     = var.subnet_name
    project                  = var.project_id
    network                  = google_compute_network.this.id
    region                   = var.region
    ip_cidr_range            = var.subnet_cidr
    private_ip_google_access = var.reach_api
    description              = "Managed by terraform: main subnet for ${var.environment} API traffic"
}

resource "google_compute_global_address" "this" {
      name          = "${var.network_name}-reserved-ip"
      project       = var.project_id
      purpose       = "VPC_PEERING"
      prefix_length = 16
      address_type  = "INTERNAL"
      network       = google_compute_network.this.id
      description   = "Address range reserved for private service access such as Cloud SQL in ${var.environment} VPC"
}

resource "google_service_networking_connection" "this" {
    network                 = google_compute_network.this.id
    service                 = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.this.name]
}