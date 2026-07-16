output "namespace" {
  description = "Kubernetes namespace containing monitoring components"
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "prometheus_release_name" {
  description = "Name of the Prometheus Helm release"
  value       = helm_release.prometheus.name
}

output "prometheus_service_name" {
  description = "Name of the Prometheus server Kubernetes Service"
  value       = "${helm_release.prometheus.name}-server"
}

output "grafana_release_name" {
  description = "Name of the Grafana Helm release"
  value       = helm_release.grafana.name
}

output "grafana_service_name" {
  description = "Name of the Grafana Kubernetes Service"
  value       = helm_release.grafana.name
}

output "grafana_admin_secret_name" {
  description = "Name of the Kubernetes Secret containing Grafana admin credentials"
  value       = helm_release.grafana.name
}
