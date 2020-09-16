resource "helm_release" "vault" {
  depends_on = [
      kubernetes_secret.google-application-credentials,
  ]
  name = "vault"
  # Depending on deprecation of data.helm_repository
  # repository = "${data.helm_repository.vault.metadata[0].name}"
  repository = "https://helm.releases.hashicorp.com"
  chart  = "vault"
  create_namespace = false
  namespace = kubernetes_namespace.vault.metadata.0.name
  force_update = true

  values = [
      google_storage_bucket_object.vault-config.content
  ]
}

# Using the "Kubernetes Ingres NGINX" https://github.com/kubernetes/ingress-nginx
resource "helm_release" "nginx" {
  depends_on = [
      helm_release.vault,
  ]
  name = "ingress-nginx"
  # Depending on deprecation of data.helm_repository
  # repository = "${data.helm_repository.vault.metadata[0].name}"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart  = "ingress-nginx"
  version = "2.16.0"
  create_namespace = false
  namespace = kubernetes_namespace.nginx.metadata.0.name
  force_update = true

  values = [ 
    google_storage_bucket_object.nginx-config.content
#     <<EOF
# fullnameOverride: "vault-nginx"
# rbac:
#   create: true
# controller:
#   name: "vault-nginx"
#   ingressClass: "nginx"
#   extraArgs:
#     enable-ssl-passthrough: true
# service:
#   externalTrafficPolicy: "Local"
# tcp:
#   8201: "${helm_release.vault.metadata.0.namespace}/vault-active:8201"
# EOF
  ]
}