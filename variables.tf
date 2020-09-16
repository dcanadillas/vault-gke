variable "gcp_region" {
  description = "Cloud region"
}
variable "gcp_project" {
  description = "Cloud GCP project"
}
variable "node_type" {
  description = "Machine type for nodes"
  default = "n1-standard-2"
}
variable "gcp_zone" {
  description = "availability zones"
}
variable "gke_cluster" {
  description = "Name of your cluster  "
}
variable "numnodes" {
  description = "Number of nodes of the cluster"
  default=3
}
variable "vault_nodes" {
  description = "Number of Vault nodes (pods) of the Vault cluster"
  default=3
}
variable "vault_hostname" {
  description = "FQDN of your Vault cluster"
  default=""
}
variable "regional_k8s" {
  description = "Set this to true if you want regional cluster with a master per zone"
  default = false
}
variable "owner" {
  description = "Owner name to tag clusters"
}
variable "gcs_bucket" {
  description = "Bucket to save template files created"
}
variable "key_ring" {
  description = "KMS Keyring name"
}
variable "crypto_key" {
  description = "KMS key name"
}
variable "service_account" {
  description = "Service Account to be used as scope permissions"
}
variable "default_gke" {
  description = "Set it to true if you want to speed up GKE cluster creation by creating a default NodePool"
  default = false
}
variable "vault_cert" {
  description = "TLS Vault cert"
  default = ""
}
variable "vault_ca" {
  description = "TLS Vault CA"
  default = ""
}
variable "vault_key" {
  description = "Vault key of certificate"
  default = ""
}
variable "tls" {
  description = "Enable/Disable TLS"
  default = "disabled"
}
variable "dns_zone" {
  description = "Cloud DNS zone to create record"
  default = null
}