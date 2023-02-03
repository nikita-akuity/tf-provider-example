output azure_clusters {
  value       = local.azure_clusters
  description = "List of AKS clusters"
}

output aws_clusters {
  value       = local.aws_clusters
  description = "List of EKS clusters"
}

output gcp_clusters {
  value       = local.gcp_clusters
  description = "List of GKE clusters"
}

output argocd_url {
  value       = "https://${akp_instance.example.hostname}"
  description = "Url of Argo CD instance"
}
