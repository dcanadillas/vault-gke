
# output "gke_ca_certificate" {
#   value = base64decode(module.gke.ca_certificate)
# }
# output "jx-requirements" {
#   value = "https://storage.cloud.google.com/${google_storage_bucket_object.jx-requirements.bucket}/${google_storage_bucket_object.jx-requirements.output_name}"
#   # value = google_storage_bucket_object.jx-requirements.self_link
# }
output "vault-config" {
  value = module.k8s.vault-yaml
}
output "nginx-config" {
  value = module.k8s.nginx-yaml
}
output "k8s_endpoint" {
  value = module.gke.cluster_endpoint
}
output "vault_certs" {
  description = "Base 64 encoded certificates and key values used by Vault nodes"
  value = module.k8s.vault_ca
}
