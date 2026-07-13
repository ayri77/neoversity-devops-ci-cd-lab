resource "helm_release" "argo_cd" {
  name             = "argocd"
  namespace        = var.namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true

  wait    = true
  timeout = 900

  values = [
    file("${path.module}/values.yaml")
  ]
}