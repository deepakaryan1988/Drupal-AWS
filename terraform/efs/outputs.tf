output "efs_id" {
  value = aws_efs_file_system.this.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.this.dns_name
}

output "efs_access_point_id" {
  value = aws_efs_access_point.drupal_ap.id
}
