# --- Rol IAM para AWS Systems Manager (SSM Session Manager) y Lambda ---
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

# Permiso para que la EC2 también pueda invocar funciones Lambda por SDK/CLI
resource "aws_iam_policy" "lambda_invoke" {
  name_prefix = "${var.name}-lambda-invoke-"
  description = "Permite a la EC2 invocar funciones Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.ssm.name
  policy_arn = aws_iam_policy.lambda_invoke.arn
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

  # Salida a internet para actualizaciones, descargas y conexion con AWS SSM / Lambda
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

              # Hardening de seguridad: Ocultar banners y firmas del servidor web
              echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
              echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf

              systemctl start httpd
              systemctl enable httpd

              cat <<'HTMLEOF' > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="es">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Portal Corporativo Seguro</title>
                <style>
                  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a; color: #f8fafc; text-align: center; padding: 40px 20px; }
                  .container { max-width: 650px; margin: 0 auto; background: #1e293b; padding: 35px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.4); border: 1px solid #334155; }
                  h1 { color: #38bdf8; margin-bottom: 8px; font-size: 26px; }
                  .tag { display: inline-block; background: #0284c7; color: white; padding: 4px 14px; border-radius: 999px; font-size: 13px; font-weight: 600; margin-bottom: 20px; }
                  .box { background: #0f172a; border: 1px solid #334155; border-radius: 10px; padding: 18px; margin: 20px 0; text-align: left; }
                  .box h3 { margin-top: 0; color: #f59e0b; font-size: 16px; }
                  button { background: #22c55e; color: #0f172a; border: none; font-weight: 700; padding: 14px 28px; font-size: 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s; }
                  button:hover { background: #16a34a; color: white; transform: translateY(-2px); }
                  #output { margin-top: 20px; padding: 16px; border-radius: 8px; background: #020617; border: 1px solid #1e293b; display: none; text-align: left; font-family: monospace; font-size: 13px; word-break: break-all; }
                </style>
              </head>
              <body>
                <div class="container">
                  <h1>🛡️ Portal Web de Infraestructura</h1>
                  <div class="tag">Instancia en Subred Privada</div>
                  <p>Nodo de servicio: <b style="color:#38bdf8;">HOST_PLACEHOLDER</b></p>
                  
                  <div class="box">
                    <h3>⚡ Servicio Backend Integrado</h3>
                    <p style="margin: 0 0 15px 0; font-size: 14px; color: #94a3b8;">
                      Haz clic para enviar una solicitud de procesamiento seguro al servicio backend:
                    </p>
                    <button onclick="ejecutarBackend()">Consultar Servicio Backend</button>
                    <div id="output"></div>
                  </div>
                </div>

                <script>
                  async function ejecutarBackend() {
                    const out = document.getElementById('output');
                    out.style.display = 'block';
                    out.style.color = '#38bdf8';
                    out.innerHTML = '⏳ Procesando petición con el backend...';
                    
                    try {
                      const url = "${var.lambda_url}";
                      if (!url) {
                        out.style.color = '#f87171';
                        out.innerHTML = '⚠️ Servicio backend no configurado.';
                        return;
                      }
                      const response = await fetch(url);
                      const data = await response.json();
                      out.style.color = '#4ade80';
                      out.innerHTML = '<b>✅ Respuesta del servicio backend (200 OK):</b><br><br>' + JSON.stringify(data, null, 2);
                    } catch (err) {
                      out.style.color = '#f87171';
                      out.innerHTML = '❌ Error al conectar con el backend: ' + err.message;
                    }
                  }
                </script>
              </body>
              </html>
              HTMLEOF

              # Inyectar el hostname real de la instancia
              sed -i "s/HOST_PLACEHOLDER/$(hostname -f)/g" /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name}-instance"
    })
  }
}
