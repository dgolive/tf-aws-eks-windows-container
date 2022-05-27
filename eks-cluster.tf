module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets


  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
    #key_pair_name   = "/home/mibre/terraform/aws/eks/tf-aws-eks-windows-container/windows.key"


  }

  worker_groups = [
    {
      name                          = "windows-wg"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 1
      platform                      = "windows"
      key_name                      = "windows-key"
    },
    {
      name                          = "linux-wg"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
      platform                      = "linux"
      #key_name                      = "/home/mibre/terraform/aws/eks/tf-aws-eks-windows-container/linux.key"
    },
  ]   
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
