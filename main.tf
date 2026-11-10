module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type = var.instance_type
  key_name      = "user1"
  monitoring    = true
  subnet_id     = module.vpc.azs[0]
  ami = data.aws_ami.al2023.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
data "aws_ami" "al2023" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "al2023-ami-2023.*-86_64" ]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
