variable "db_name" {
  type        = string
  description = "Name of the RDS database"
  default     = "drupaldb"
}

variable "db_username" {
  type        = string
  default     = "admin"
}

variable "db_password" {
  type        = string
  default     = "Deepak_12345!"
}
