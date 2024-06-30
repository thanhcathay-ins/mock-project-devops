output "jenkins_gitea_private_ip" {
  value = module.jenkins-gitea-server.public_ip
}

output "basehost_public_ip" {
  value = module.bastion_host.public_ip
}

