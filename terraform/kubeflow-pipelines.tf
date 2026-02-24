# Production pattern: GitOps only. No null_resource, no kubectl in Terraform.
#
# Terraform creates a single Argo CD Application (app-of-apps) that syncs from your repo
# path deploy/argocd-applications. All Kubeflow Pipelines (and any other apps) are defined
# there as Application manifests; Argo CD syncs them from upstream or from repo.
#
# Set repository_url to your Git repo (e.g. https://github.com/your-org/mlops).
# See deploy/argocd-applications/ for the KFP Application definitions.

resource "kubernetes_manifest" "argocd_app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "mlops-apps"
      namespace = "argocd"
      labels = {
        "app.kubernetes.io/name"   = "mlops-apps"
        "app.kubernetes.io/part-of" = "mlops"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.repository_url
        path           = "deploy/argocd-applications"
        targetRevision = "HEAD"
        directory = {
          recurse = true
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
  depends_on = [helm_release.argocd]
}
