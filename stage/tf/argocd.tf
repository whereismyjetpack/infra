resource "helm_release" "argocd" {
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    namespace = "argocd"
    chart = "argo-cd"
    wait = true
    version = "7.2.0"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_secret" "gitops_repo" {
  data = {
    type = "git"
    url = var.gitops_repo
    username = var.github_username
    password = var.github_password
  }

  metadata {
    namespace = "argocd"
    name = "gitops-repo"
    labels = {
       "argocd.argoproj.io/secret-type": "repository"
    }
  }
}

resource "null_resource" "setup_argocd" {
  depends_on = [
    helm_release.argocd
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f gitops/applications/argocd/applicationset.yaml"
  }
}