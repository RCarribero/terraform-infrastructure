data "aws_caller_identity" "current" {}

# --- 1. Rol IAM para el Equipo de Desarrollo ---
# Los desarrolladores asumen este rol en lugar de usar credenciales de la cuenta root
resource "aws_iam_role" "infra_developer" {
  name = "${var.name}-infra-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# --- 2. Política de Permisos: EC2, Auto Scaling, Load Balancers y SSM ---
# Concede permisos específicos para actualizar la infraestructura y conectarse a las máquinas
resource "aws_iam_policy" "infra_developer_policy" {
  name        = "${var.name}-infra-developer-policy"
  description = "Permite al equipo de desarrollo actualizar EC2, ASG, ALB y conectarse por SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Control de Cómputo y Balanceo
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "autoscaling:*",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      # Conexión remota por SSM Session Manager (sin necesidad de SSH ni clave root)
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssm:DescribeInstanceInformation",
          "ssm:GetConnectionStatus"
        ]
        Resource = "*"
      },
      # Lectura de estado de red y métricas
      {
        Effect = "Allow"
        Action = [
          "vpc:Describe*",
          "tag:GetResources",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "infra_developer_attach" {
  role       = aws_iam_role.infra_developer.name
  policy_arn = aws_iam_policy.infra_developer_policy.arn
}

# --- 3. Grupo IAM para Desarrolladores ---
resource "aws_iam_group" "developers" {
  name = "${var.name}-developers-group"
}

# Permite a los usuarios del grupo asumir el rol de infraestructura
resource "aws_iam_policy" "assume_developer_role" {
  name        = "${var.name}-assume-developer-role-policy"
  description = "Permite asumir el rol de infraestructura de desarrollo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.infra_developer.arn
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_group_policy_attachment" "group_assume_role" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.assume_developer_role.arn
}

# --- 4. Usuarios IAM para el equipo de desarrollo ---
resource "aws_iam_user" "dev_users" {
  for_each = toset(var.developer_users)
  name     = each.value
  tags     = var.tags
}

resource "aws_iam_user_group_membership" "dev_users_membership" {
  for_each = toset(var.developer_users)
  user     = aws_iam_user.dev_users[each.value].name
  groups   = [aws_iam_group.developers.name]
}

