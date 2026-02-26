output "network_name" {
    value = google_compute_network.this.name
}

output "network_id" {
    value = google_compute_network.this.id
    depends_on = [ google_service_networking_connection.this ]
}

output "subnet_name" {
    value = google_compute_subnetwork.this.name
}

output "subnet_id" {
    value = google_compute_subnetwork.this.id
}