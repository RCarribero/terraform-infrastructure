# --- 1. Data Source AMI (Amazon Linux 2023) ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# --- 2. Servicio de Red (VPC Multi-AZ) ---
module "vpc" {
  source = "./modules/vpc"

  name                 = "my-vpc-${var.environment}"
  cidr_block           = "10.0.0.0/16"
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway   = var.enable_nat_gateway

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 3. Servicio de Balanceo (ELB centralizado de cara al exterior) ---
# El Load Balancer es el ÚNICO componente en la zona pública con salida al exterior
module "alb" {
  source = "./modules/alb"

  name           = "app-alb-${var.environment}"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 4. Servicio de Cómputo (EC2 100% privadas, SIN IP pública) ---
module "ec2" {
  source = "./modules/ec2"

  name                        = "app-ec2-${var.environment}"
  vpc_id                      = module.vpc.vpc_id
  ami_id                      = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  alb_security_group_id       = module.alb.alb_security_group_id
  associate_public_ip_address = false # Sin IP publica

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 5. Servicio de Auto Scaling (Instancias repartidas en las subredes privadas) ---
module "autoscaling" {
  source = "./modules/autoscaling"

  name = "app-asg-${var.environment}"
  # Se despliegan EXCLUSIVAMENTE en las subredes privadas (1 en eu-west-1a y 1 en eu-west-1b)
  subnet_ids         = module.vpc.private_subnets
  launch_template_id = module.ec2.launch_template_id
  target_group_arns  = [module.alb.target_group_arn]

  min_size         = 2
  max_size         = 4
  desired_capacity = 2 # 2 instancias: AWS coloca automaticamente una en cada subred privada

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 6. Seguridad e Identidad (IAM: Roles y Grupo para Desarrolladores) ---
# Evita el uso de la cuenta root y da permisos de actualizacion exclusivamente a desarrollo
module "iam" {
  source = "./modules/iam"

  name            = "app-${var.environment}"
  developer_users = ["dev-lead", "dev-engineer"]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
