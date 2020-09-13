fullnameOverride: "vault-nginx"
rbac:
  create: true
controller:
  name: "vault-nginx"
  ingressClass: "nginx"
  extraArgs:
    enable-ssl-passthrough: true
service:
  externalTrafficPolicy: "Local"
tcp:
  8201: "${vault_namespace}/vault-active:8201"