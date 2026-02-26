resource "google_compute_global_address" "this" {
    project =   var.project_id
    name    = "${var.prefix_name}-lb-ip"
}

resource "google_compute_region_network_endpoint_group" "this" {
    project               = var.project_id
    name                  = "${var.prefix_name}-neg"
    region                = var.region
    network_endpoint_type = "SERVERLESS"

    cloud_run {
        service = var.cloud_run_service_name
    }
}

resource "google_compute_backend_service" "this" {
    project     = var.project_id
    name        = "${var.prefix_name}-backend" 
    protocol    = "HTTP"
    port_name   = "http"
    timeout_sec = 30
    enable_cdn  = false

    backend {
      group = google_compute_region_network_endpoint_group.this.id
    }
}


resource "google_compute_url_map" "this" {
    project         = var.project_id
    name            = "${var.prefix_name}-url-map"
    default_service = google_compute_backend_service.this.id
}

resource "google_compute_target_http_proxy" "this" {
    project = var.project_id
    name    = "${var.prefix_name}-http-proxy"
    url_map = google_compute_url_map.this.id
}

resource "google_compute_global_forwarding_rule" "this" {
    project    = var.project_id
    name       = "${var.prefix_name}-forwarding-rule"
    target     = google_compute_target_http_proxy.this.id
    ip_address = google_compute_global_address.this.id
    port_range = "80"
}


