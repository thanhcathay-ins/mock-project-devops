output "jenkins_gitea_private_ip" {
  value = module.jenkins_gitea_server.public_ip
}

output "bastion_ip" {
  value = module.bastion_host.private_ip
}
