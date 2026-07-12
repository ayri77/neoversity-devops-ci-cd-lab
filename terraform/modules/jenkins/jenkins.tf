resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.9.32"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}