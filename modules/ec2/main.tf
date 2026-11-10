# --- Rol IAM para AWS Systems Manager (SSM Session Manager) ---
# Permite acceder de forma remota y segura a la consola sin abrir el puerto 22 SSH
resource "aws_iam_role" "ssm" {
  name_prefix = "${var.name}-ssm-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name_prefix = "${var.name}-ssm-profile-"
  role        = aws_iam_role.ssm.name
  tags        = var.tags
}

# --- Security Group de Cómputo (Zero-Trust) ---
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group para instancias EC2 (trafico exclusivo desde ALB)"
  vpc_id      = var.vpc_id

  # Trafico HTTP permitido UNICAMENTE desde el Load Balancer
  ingress {
    description     = "HTTP solo desde el Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Salida a internet para actualizaciones, descargas y conexion con AWS SSM
  egress {
    description = "Salida total a internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

# --- Launch Template para EC2 ---
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.ssm.arn
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [aws_security_group.this.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Servidor EC2 ($(hostname -f)) - Arquitectura Profesional</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name}-instance"
    })
  }
}
