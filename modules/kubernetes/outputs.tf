output "vault-yaml" {
  value = "https://storage.cloud.google.com/${google_storage_bucket_object.vault-config.bucket}/${google_storage_bucket_object.vault-config.output_name}"
}
output "nginx-yaml" {
  value = "https://storage.cloud.google.com/${google_storage_bucket_object.nginx-config.bucket}/${google_storage_bucket_object.nginx-config.output_name}"
}
output "vault_ca" {
  value = kubernetes_secret.certs.data
}