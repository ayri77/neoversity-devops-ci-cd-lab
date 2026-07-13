locals {
  eks_oidc_provider_url = replace(
    aws_eks_cluster.main.identity[0].oidc[0].issuer,
    "https://",
    ""
  )
}

# OIDC provider used by IAM Roles for Service Accounts (IRSA)
resource "aws_iam_openid_connect_provider" "oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# IAM role assumed by the EBS CSI controller through IRSA
resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "${var.cluster_name}-ebs-csi-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${local.eks_oidc_provider_url}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Grant the EBS CSI controller permission to manage EBS volumes
resource "aws_iam_role_policy_attachment" "ebs_csi_irsa_policy" {
  role       = aws_iam_role.ebs_csi_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Install the official AWS EBS CSI Driver add-on
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn

  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.general,
    aws_iam_openid_connect_provider.oidc,
    aws_iam_role_policy_attachment.ebs_csi_irsa_policy
  ]
}