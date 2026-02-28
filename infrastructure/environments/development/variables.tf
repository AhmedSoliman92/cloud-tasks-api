variable "project_id" {
    type = string
}

variable "region" {
    type = string
    default = "europe-west1"
}

variable "gcp_services_list" {
    description = "APIs list which are necessay for GCO resources"
    type = list(string)
    default = [ 
        "artifactregistry.googleapis.com",
        "compute.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
        "iam.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "serviceusage.googleapis.com",
        "secretmanager.googleapis.com",
        "run.googleapis.com"
     ]
  }

variable "username" {
    type = string  
}

variable "password" {
    type = string
    sensitive = true  
}

variable "image" {
    type = string  
}