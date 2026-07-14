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

resource "helm_release" "argo_apps" {
  name             = "${helm_release.argo_cd.name}-apps"
  namespace        = var.namespace
  chart            = "${path.module}/charts"
  create_namespace = false

  wait    = true
  timeout = 300

  values = [
    file("${path.module}/charts/values.yaml")
  ]

  depends_on = [
    helm_release.argo_cd
  ]
}