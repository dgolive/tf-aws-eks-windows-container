resource "kubernetes_namespace" "eks-sample-app" {
  metadata {
    name = "eks-sample-app"
  }
  provisioner "local-exec" {
      command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  }
  provisioner "local-exec" {
    command = "aws iam attach-role-policy --role-name ${var.eks_role_name} --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f modules/windows-setup/vpc-resource-controller-configmap.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f modules/windows-setup/workloads/windows/sample1/sample1.yaml"
  }
}