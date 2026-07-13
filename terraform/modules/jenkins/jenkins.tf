locals {
  oidc_provider_host = replace(
    var.oidc_provider_url,
    "https://",
    ""
  )
}

resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_provider_host}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_host}:sub" = "system:serviceaccount:jenkins:jenkins-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]

        Resource = "*"
      }
    ]
  })
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.9.32"
  create_namespace = true
  timeout          = 900

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_service_account_v1" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"
    namespace = "jenkins"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn
    }
  }

  depends_on = [
    helm_release.jenkins
  ]
}