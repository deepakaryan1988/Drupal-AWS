variable "efs_name" {
  type        = string
  default     = "drupal-efs"
  description = "Name token for the EFS volume"
}
variable "efs_uid" {
  description = "POSIX UID to access EFS (e.g. www-data)"
  type        = number
  default     = 33
}

variable "efs_gid" {
  description = "POSIX GID to access EFS (e.g. www-data)"
  type        = number
  default     = 33
}
