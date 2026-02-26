variable "project_id" {
    type = string
}

variable "environment" {
    type = string
}

variable "region" {
    type = string
    default = "europe-west1"
}

variable "network_name" {
    type = string
}

variable "subnet_name" {
    type = string
}

variable "subnet_cidr" {
    type = string
}

variable "reach_api" {
    type = bool
    default = false
}