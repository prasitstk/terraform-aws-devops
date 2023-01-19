###########
# Outputs #
###########

output "bastion_host_public_dns" {
  value = aws_instance.bastion_host_i.public_dns 
}

output "bastion_host_key_pair_private_key_pem" {
  value     = tls_private_key.bastion_host_tls_private_key.private_key_pem
  sensitive = true
}

output "db_host" {
  value = aws_db_instance.db_dbi.address  
}

output "db_port" {
  value = aws_db_instance.db_dbi.port
}

output "db_name" {
  value = aws_db_instance.db_dbi.db_name
}

output "db_username" {
  value = aws_db_instance.db_dbi.username
}

output "db_password" {
  value = aws_db_instance.db_dbi.password
  sensitive = true
}
