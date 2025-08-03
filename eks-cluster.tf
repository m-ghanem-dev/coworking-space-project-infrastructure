module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.k8s_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  enable_cluster_creator_admin_permissions    = true
  cluster_endpoint_public_access              = true
  cluster_endpoint_private_access             = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3

      instance_types = ["t3.medium"]
      subnet_ids     = module.vpc.public_subnets
    }
  }
}

resource "aws_security_group_rule" "allow_ports" {
  type              = "ingress"
  from_port         = 30008
  to_port           = 30008
  protocol          = "tcp"
  security_group_id = module.eks.node_security_group_id
  cidr_blocks       = ["0.0.0.0/0"] # should be security group of load balancer (source_security_group_id = sg id of load balancer)
  description       = "Allow TCP traffic from anywhere to port 30008 (backend node port)"
}

