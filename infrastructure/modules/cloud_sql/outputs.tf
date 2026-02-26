output "instance_name" {
    value = google_sql_database_instance.this.name  
}

output "database_name" {
    value = google_sql_database.this.name  
}

output "username" {
    value = google_sql_user.this.name
}

output "user_password" {
    value = google_sql_user.this.password  
}

output "connection_name" {
    value = google_sql_database_instance.this.connection_name  
}

output "private_ip" {
    value = google_sql_database_instance.this.private_ip_address 
}