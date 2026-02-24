output "eks_cluster_name" {
  description = "EKS cluster name (for kubectl and ArgoCD)."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "s3_data_bucket_name" {
  description = "S3 bucket name for training data."
  value       = aws_s3_bucket.data.id
}

# After apply, run: aws eks update-kubeconfig --region <region> --name <cluster_name>
output "kubeconfig_command" {
  description = "Run this to configure kubectl for the cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "argocd_admin_secret_command" {
  description = "Get ArgoCD initial admin password (run after cluster is ready)."
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "kfp_ui_port_forward" {
  description = "Port-forward KFP UI (run after Kubeflow Pipelines app is synced in Argo CD)."
  value       = "kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80"
}
