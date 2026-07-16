resource "kubernetes_namespace_v1" "django" {
  metadata {
    name = "django"
  }

  depends_on = [
    module.eks
  ]
}

resource "kubernetes_secret_v1" "django_app" {
  metadata {
    name      = "django-app-secrets"
    namespace = kubernetes_namespace_v1.django.metadata[0].name
  }

  type = "Opaque"

  data_wo = {
    SECRET_KEY        = var.django_secret_key
    POSTGRES_HOST     = module.rds.database_host
    POSTGRES_PORT     = tostring(module.rds.database_port)
    POSTGRES_DB       = "myapp"
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = var.db_password
  }

  data_wo_revision = var.django_secret_revision + var.db_password_revision
}
