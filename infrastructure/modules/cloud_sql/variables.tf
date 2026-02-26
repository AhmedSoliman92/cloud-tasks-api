variable "project_id" {
    type = string
}

variable "region" {
    type = string  
}

variable "deletion_protection" {
    type = string  
}

variable "instance_name" {
    type = string
}

variable "vpc_network_id" {
    type = string  
}

variable "database_name" {
    type = string  
}

variable "username" {
    type = string
}

variable "password" {
    type      = string
    sensitive = true  
}