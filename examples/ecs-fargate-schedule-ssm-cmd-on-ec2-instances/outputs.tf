###########
# Outputs #
###########

output "app_private_key_pem" {
  value     = tls_private_key.app_tls_private_key.private_key_pem
  sensitive = true
}

output "env_resourcegroup_grp_name" {
  value = aws_resourcegroups_group.env_resourcegroup_grp.name
}

output "app_img_repo_url" {
  value = aws_ecr_repository.app_img_repo.repository_url
}

output "app_img_repo_name" {
  value = "${var.app_img_repo_name}"
}
