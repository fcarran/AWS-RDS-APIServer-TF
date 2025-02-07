output "url" {
  value = "https://${aws_lb.default.dns_name}"
}

output "aws_ssm_parameter" {
  value = aws_ssm_parameter.database_url.name
}

# Sensitve outputs
output "aws_ssm_parameter_value" {
  value     = aws_ssm_parameter.database_url.value
  sensitive = true
}

output "rds_name" {
  value       = aws_db_instance.default.id
  description = "RDS instance name"
  sensitive   = true
}

output "rds_hostname" {
  value       = aws_db_instance.default.endpoint
  description = "RDS instance hostname"
  sensitive   = true
}

output "rds_public_ip" {
  value       = aws_db_instance.default.address
  description = "RDS instance public IP"
  sensitive   = true

}

output "rds_port" {
  value       = aws_db_instance.default.port
  description = "RDS instance port"
  sensitive   = true
}

output "rds_username" {
  value       = aws_db_instance.default.username
  description = "RDS instance username"
  sensitive   = true
}

output "rds_password" {
  value       = random_password.database.result
  description = "RDS random password"
  sensitive   = true
}