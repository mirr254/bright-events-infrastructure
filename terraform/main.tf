locals {
  cluster_name = "saija-eks-${random_string.suffix.result}"
  cluster_version = 1.18
}

resource "random_string" "suffix" {
  length   = 5
  special  = false
}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "2.63.0"

  name            = "saija-vpc"
  cidr            = "10.0.0.0/16"
  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true 
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}"  = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}"  = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}"  = "shared"
    "kubernetes.io/role/internal_elb"              = "1"
  }


}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  cluster_version = local.cluster_version
  subnets      = module.vpc.private_subnets
  vpc_id        = module.vpc.vpc_id

  tags = {
    Environment = "Dev"
    GitRepo     = "saiju-tf-k8s-docker"
    GitOrg      = "mirr254"
  }


  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      asg_max_size                  = 4 
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },

    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_max_size                  = 4
      asg_desired_capacity          = 2
    }
  ]

}

resource "aws_security_group"  "worker_group_mgmt_one" {
  name_prefix  = "worker_group_mgmt_one"
  vpc_id       = module.vpc.vpc_id

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

# resource "aws_security_group"  "worker_group_mgmt_two" {
#   name_prefix  = "worker_group_mgmt_two"
#   vpc_id       = module.vpc.vpc_id

#   ingress {
#     from_port  = 22
#     to_port    = 22
#     protocol   = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
# }

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix   = "all_worker_mgmt"
  vpc_id        = module.vpc.vpc_id

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16"
    ]
  }
}

provider "kubernetes" {
  load_config_file          = "false"
  host                      = data.aws_eks_cluster.cluster.endpoint
  token                     = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate    = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "aws" {
  region  = var.region
}