## We are using a token from "data.google_client_config.default.access_token"
## passed in the var.token variable
data "google_client_config" "default" {
}
# data "google_container_cluster" "gke_cluster" {
#     name = var.cluster_name
#     location = var.location
# }
# We create some local vars to make it easier later
# locals {
#   cluster_ca = data.google_container_cluster.gke_cluster.master_auth
#   hostk8s = data.google_container_cluster.gke_cluster.endpoint
# }
provider "google" {
  project = var.gcp_project
  region = var.gcp_region
}

provider "helm" {
  kubernetes {
    load_config_file = false

    # We use this conditional to be sure that when the cluster is created there is no dependencies issues
    # host = data.google_container_cluster.gke_cluster.endpoint
    # host = local.hostk8s!= null ? local.hostk8s : var.cluster_endpoint
    host = var.cluster_endpoint

    # username = "${var.username}"
    # password = "${var.password}"
    token = data.google_client_config.default.access_token

    # client_certificate = "${base64decode(var.client_certificate)}"
    # client_key = "${base64decode(var.client_key)}"

    # We use this conditional to be sure that when the cluster is created there is no dependencies issues
    # cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate )
    # cluster_ca_certificate = local.cluster_ca != null ? base64decode(local.cluster_ca.0.cluster_ca_certificate) : base64decode(var.ca_certificate)
    cluster_ca_certificate = base64decode(var.ca_certificate)
  }
}
provider "kubernetes" {
    load_config_file = false

    # host = data.google_container_cluster.gke_cluster.endpoint
    # host = local.hostk8s!= null ? local.hostk8s : var.cluster_endpoint
    host = var.cluster_endpoint
    # insecure = true

    # username = "${var.username}"
    # password = "${var.password}"
    token = data.google_client_config.default.access_token

    # client_certificate = "${base64decode(var.client_certificate)}"
    # client_key = "${base64decode(var.client_key)}"

    # We use this conditional to be sure that when the cluster is created there is no dependencies issues
    # cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate )
    # cluster_ca_certificate = local.cluster_ca != null ? base64decode(local.cluster_ca.0.cluster_ca_certificate) : base64decode(var.ca_certificate)
    cluster_ca_certificate = base64decode(var.ca_certificate)
}

# The Helm provider creates the namespace, but if we want to create it manually would be with following lines
resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.cluster_namespace
  }
}
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "ingress"
  }
}

# Creating dynamically a hostname list to use later on template
data "null_data_source" "hostnames" {
  count = var.nodes
  inputs = {
      hostnames = "vault-${count.index}"
  }
}
locals {
  hostnames = data.null_data_source.hostnames.*.inputs.hostnames
}

# Let's create a secret with the json credentials to use KMS autounseal
resource "google_service_account_key" "gcp_sa_key" {
  service_account_id = var.gcp_service_account.name
}
resource "kubernetes_secret" "google-application-credentials" {
  metadata {
    name = "kms-creds"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.gcp_sa_key.private_key)
  }
}
resource "kubernetes_secret" "certs" {
  metadata {
    name = "vault-server-tls"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }
  data = {
    "vault.crt" = var.vault_cert
    "vault.ca" = var.vault_ca
    "vault.key" = var.vault_key
  }
}


# Because we are executing remotely using TFC/TFE we want to save our templates in a Cloud bucket
resource "google_storage_bucket_object" "vault-config" {
  name   = "${var.cluster_name}.yml"
  content = templatefile("${path.root}/templates/vault_values.yaml.tpl",{
            hostname = var.hostname,
            vault_nodes = var.nodes
            vault_repo = var.vault_repo,
            vault_version = var.vault_version,
            hosts = local.hostnames,
            gcp_project = var.gcp_project,
            gcp_region = var.gcp_region,
            key_ring = var.key_ring
            crypto_key = google_kms_crypto_key.crypto_key.name,
            kms_creds = kubernetes_secret.google-application-credentials.metadata[0].name,
            http = var.tls == "enabled" ? "https" : "http",
            disable_tls = var.tls == "enabled" ? false : true,
            tls = var.tls
            })
  bucket = var.config_bucket
}

resource "google_storage_bucket_object" "nginx-config" {
  name   = "${var.cluster_name}-nginx.yml"
  content = templatefile("${path.root}/templates/nginx.yaml.tpl",{
            vault_namespace = kubernetes_namespace.vault.metadata.0.name,
            })
  bucket = var.config_bucket
}

## I you want to create the template files locally uncomment the following lines (This is not working with remote execution in TFE)
# resource "local_file" "foo" {
#     content     = templatefile("${path.root}/templates/vault_values.yaml",{
#           hostname = var.hostname,
#           vault_version = var.vault_version
#           })
#     filename = "${path.root}/templates/vault.yaml"
# }
