output "rds_endpoint" {
  value = aws_db_instance.drupal.endpoint
}

output "rds_username" {
  value = var.db_username
}

output "rds_password" {
  value = var.db_password
}

output "rds_dbname" {
  value = var.db_name
}
