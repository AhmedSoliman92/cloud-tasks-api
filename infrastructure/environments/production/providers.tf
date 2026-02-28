terraform {
  backend "gcs" {
    bucket = "cloud-task-api-prod-tf-state"
    prefix = "cloud-task-api/state"
  }
  required_providers {
    time = {
      source = "hashicorp/time"
      version = "~>0.9"
    }
  }
}

provider "google" {
  project = "${var.project_id}-prod"
  region  = var.region
}