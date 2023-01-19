###########
# Outputs #
###########

output "sys_key_pair_private_key_pem" {
  value     = tls_private_key.sys_tls_private_key.private_key_pem
  sensitive = true
}

output "openvpn_host_eip" {
  value = aws_eip.openvpn_host_eip.public_ip
}

output "win_host_private_ip" {
  value = aws_instance.win_host_i.private_ip
}

output "linux_host_private_ip" {
  value = aws_instance.linux_host_i.private_ip
}
