output "service_name" {
    value = google_cloud_run_service.this.name
}

output "service_url" {
    value = google_cloud_run_service.this.status[0].url
}  
