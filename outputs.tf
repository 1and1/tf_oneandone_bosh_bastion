output "bastion_ip" {
  value = "${oneandone_server.bastion.ips.0.ip}"
}
