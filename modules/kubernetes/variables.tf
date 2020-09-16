# variable "username" {
#   description = "The Kubernetes username"
#   default = "admin"
# }
# variable "password" {
#   description = "A password to be generated during provisioning"
# }
# variable "token" {
#   description = "The Kubernetes client token"
# }
variable "cluster_namespace" {
  description = "Namespace to be created for the cluster"
}
variable "cluster_endpoint" {
  description = "Endpoint host of the K8s cluster"
}
variable "cluster_name" {
  description = "Name of the K8s cluster"
}
variable "location" {
  description = "Location of K8s cluster"
}
variable "gcp_project" {
  description = "Cloud GCP project"
}
variable "gcp_region" {
  description = "Cloud GCP project"
}


# variable "client_certificate" {
#   description = "The K8s client cert"
# }
variable "ca_certificate" {
  description = "The K8s ca cert"
}
# variable "client_key" {
#   description = "The Kubernetes client key"
# }
variable "vault_version" {
  description = "Version of Vault to be deployed"
  default = "1.5.0_ent"
}
variable "hostname" {
  description = "The DNS hostname for Vault"
  default = ""
}
variable "config_bucket" {
  description = "Cloud bucket to save config generated files"
}
variable "vault_repo" {
  description = "Vault Helm repositorie to use"
  default = "hashicorp/vault-enterprise"
}
variable "nodes" {
  description = "Number of nodes/pods of the cluster"
}
variable "gcp_service_account" {
  description = "SA to create credentials for KMS auto-unseal"
}
variable "key_ring" {
  description = "KMS Keyring name"
}
variable "crypto_key" {
  description = "KMS key name"
}
variable "vault_cert" {
  description = "TLS Vault cert"
}
variable "vault_ca" {
  description = "TLS Vault CA"
}
variable "vault_key" {
  description = "Vault key of certificate"
}
variable "tls" {
  description = "Enabling/Disabling HTTPS"
}
variable "dns_zone" {
  description = "Cloud DNS zone to create record"
  default = null
}