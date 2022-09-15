resource "kubernetes_namespace" "crossplane-system" {
  metadata {
    name = "crossplane-system"
  }
}


data "template_file" "creds_conf" {
  template = file("${path.module}/creds.conf")
  vars = {
    aws_access_key_id = var.crossplane_access_key_id
    aws_secret_access_key = var.crossplane_secret_access_key
  }
}

resource "kubernetes_secret" "aws-creds" {
  data = {
    creds = data.template_file.creds_conf.rendered
  }
  metadata {
    namespace = "crossplane-system"
    name = "aws-creds"
  }
}