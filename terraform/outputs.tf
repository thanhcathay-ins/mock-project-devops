output "jenkins_gitea_public_ip" {
  value = module.jenkins-gitea-server.public_ip
}

output "docker_registry_public_ip" {
  value = module.docker_registry.public_ip
}

output "eks_cluster_name" {
  value = module.eks_cluster.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.eks_cluster_endpoint
}