data "kubectl_path_documents" "argocd" {
  pattern = "./gitops/applications/argocd/*.yaml"
}

resource "kubectl_manifest" "argocd" {
    count     = length(data.kubectl_path_documents.argocd.documents)
    yaml_body = element(data.kubectl_path_documents.argocd.documents, count.index)
    override_namespace = "argocd"
    depends_on = [kubernetes_namespace.argocd]
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