# ArgoCD installed via Helm (production pattern: infra code owns bootstrap).
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
#
# Why wait_for_jobs = false: The chart runs a pre-install hook Job (redis-secret-init)
# that can hang in some environments (see argoproj/argo-helm#2848). With wait_for_jobs = true,
# Terraform would block until that job completes or the release times out. We only wait for
# the main Deployments/StatefulSets; the hook still runs and usually finishes quickly.
#
# Values: Tuned for a single node. Anti-affinity disabled so all pods can colocate.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.4.3"
  namespace  = "argocd"

  create_namespace = true

  wait          = true
  wait_for_jobs = false
  timeout       = 300

  values = [
    yamlencode({
      global = {
        affinity = {
          podAntiAffinity = "none"
        }
      }
      controller = {
        resources = {
          requests = { cpu = "100m", memory = "128Mi" }
          limits   = { cpu = "500m", memory = "256Mi" }
        }
      }
      server = {
        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "500m", memory = "256Mi" }
        }
      }
      repoServer = {
        resources = {
          requests = { cpu = "100m", memory = "128Mi" }
          limits   = { cpu = "1000m", memory = "512Mi" }
        }
      }
      redis = {
        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "200m", memory = "128Mi" }
        }
      }
    })
  ]

  depends_on = [module.eks]
}
