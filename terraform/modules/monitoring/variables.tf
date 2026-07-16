variable "namespace" {
  description = "Kubernetes namespace for monitoring components"
  type        = string
  default     = "monitoring"
}

variable "prometheus_release_name" {
  description = "Helm release name for Prometheus"
  type        = string
  default     = "prometheus"
}

variable "prometheus_chart_version" {
  description = "Version of the prometheus-community/prometheus Helm chart"
  type        = string
  default     = "29.17.0"
}

variable "grafana_release_name" {
  description = "Helm release name for Grafana"
  type        = string
  default     = "grafana"
}

variable "grafana_chart_version" {
  description = "Version of the grafana-community/grafana Helm chart"
  type        = string
  default     = "12.7.2"
}
