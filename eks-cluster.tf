module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets


  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"

  }

  worker_groups = [
    {
      name          = "windows-wg"
      instance_type = "m5.2xlarge"
      #additional_userdata = "echo foo bar"
      #additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity = 1
      platform             = "windows"
      ami_id               = "ami-072d3ce2cff19f1c9"
      #bootstrap_extra_args = "--container-runtime containerd --EKSClusterName ${local.cluster_name}"
      bootstrap_extra_args = "--container-runtime containerd"
      kubelet-extra-args   = "--max-pods 50"

    },
    {
      name                          = "linux-wg"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 2
      platform                      = "linux"
      bootstrap_extra_args          = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"
    },
  ]
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "windows-setup" {
  source        = "./modules/windows-setup"
  eks_role_name = module.eks.cluster_iam_role_name
  region = var.region
  cluster_name = local.cluster_name
  depends_on    = [module.eks]
}

