output "jenkins_public_ip" {
  value = module.jenkins.public_ip
}

output "gitea_public_ip" {
  value = module.gitea.public_ip
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