output "data_dbi_db_name" {
  value = aws_db_instance.src_data_dbi.db_name
}

output "data_dbi_db_address" {
  value = aws_db_instance.src_data_dbi.address
}

output "data_dbi_db_port" {
  value = aws_db_instance.src_data_dbi.port
}

output "data_dbi_db_username" {
  value = aws_db_instance.src_data_dbi.username
}

output "data_dbi_db_password" {
  value     = "${var.data_master_db_password}"
  sensitive = true
}

output "data_bucket_name" {
  value = module.tgt_data_bucket.bucket.bucket
}
