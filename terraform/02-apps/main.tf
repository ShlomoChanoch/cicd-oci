resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "6.7.11"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

data "kubernetes_service" "argocd_server_status" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "api_argocd" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "cicd-oci"
      namespace = helm_release.argocd.namespace

      annotations = {

        "argocd-image-updater.argoproj.io/image-list" = "my-app=iad.ocir.io/${var.ocir_tenancy_namespace}/${var.image_repository}"

        "argocd-image-updater.argoproj.io/my-app.update-strategy" = "digest"

        "argocd-image-updater.argoproj.io/my-app.digest.sort" = "date"

      "argocd-image-updater.argoproj.io/write-back-method" = "argocd" }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/ShlomoChanoch/cicd-oci.git"
        targetRevision = "main"
        path           = "k8s"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    helm_release.argocd_image_updater
  ]
}

resource "helm_release" "argocd_image_updater" {
  name             = "argocd-image-updater"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  version          = "0.9.1" ################ Ajuste para a versão desejada
  namespace        = helm_release.argocd.namespace
  create_namespace = false

  set {
    name  = "config.argocd.serverAddr"
    value = "https://argocd-server.${helm_release.argocd.namespace}.svc"
  }

  depends_on = [helm_release.argocd]
}

