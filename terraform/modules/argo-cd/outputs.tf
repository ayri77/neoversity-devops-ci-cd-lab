output "release_name" {
  description = "Name of the Argo CD Helm release"
  value       = helm_release.argo_cd.name
}

output "namespace" {
  description = "Namespace where Argo CD is installed"
  value       = helm_release.argo_cd.namespace
}

output "applications_release_name" {
  description = "Name of the Helm release containing Argo CD Applications"
  value       = helm_release.argo_apps.name
}