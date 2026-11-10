# --- 1. Data Source AMI (Amazon Linux 2023) ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# --- 2. Servicio de Red (VPC Multi-AZ con NAT Gateway) ---
module "vpc" {
  source = "../../modules/vpc"

  name                 = "my-vpc-${var.environment}"
  cidr_block           = "10.0.0.0/16"
  azs                  = ["${var.aws_region}a", "${var.aws_region}c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway   = var.enable_nat_gateway

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 3. Servicio de Balanceo (ALB en Subredes Públicas) ---
module "alb" {
  source = "../../modules/alb"

  name           = "app-alb-${var.environment}"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 4. Servicio Serverless (Función Lambda de Prueba) ---
module "lambda" {
  source = "../../modules/lambda"

  name = "app-lambda-${var.environment}"

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 5. Servicio de Cómputo (EC2 con IAM SSM y Subred Privada) ---
module "ec2" {
  source = "../../modules/ec2"

  name                        = "app-ec2-${var.environment}"
  vpc_id                      = module.vpc.vpc_id
  ami_id                      = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  alb_security_group_id       = module.alb.alb_security_group_id
  associate_public_ip_address = false
  lambda_url                  = module.lambda.lambda_function_url

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 6. Servicio de Auto Scaling (ASG en Subredes Privadas) ---
module "autoscaling" {
  source = "../../modules/autoscaling"

  name               = "app-asg-${var.environment}"
  subnet_ids         = module.vpc.private_subnets
  launch_template_id = module.ec2.launch_template_id
  target_group_arns  = [module.alb.target_group_arn]

  min_size         = 2
  max_size         = 6
  desired_capacity = 3

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# --- 7. Seguridad e Identidad (IAM: Roles y Grupo para Desarrolladores) ---
module "iam" {
  source = "../../modules/iam"

  name            = "app-${var.environment}"
  developer_users = ["dev-lead", "dev-engineer"]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
