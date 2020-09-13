terraform {
  required_version = ">= 0.12.26"
  backend "remote" {
  }
}

# Collect account data for AWS
# data "aws_caller_identity" "current" {}

# Collect client config for GCP
data "google_client_config" "current" {
}
data "google_service_account" "owner_project" {
  account_id = var.service_account
}
# Collect client config for Azure
# data "azurerm_client_config" {
# }

resource "google_compute_network" "container_network" {
  name = "${var.gke_cluster}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "container_subnetwork" {
  name          = "${var.gke_cluster}-subnetwork"
  description   = "auto-created subnetwork for cluster \"${var.gke_cluster}\""
  region        = var.gcp_region
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.container_network.self_link
}

module "gke" {
  source = "./modules/gke"
  region = var.gcp_region
  zone = var.gcp_zone
  project = var.gcp_project
  cluster_name = var.gke_cluster
  network = google_compute_network.container_network.self_link
  subnetwork = google_compute_subnetwork.container_subnetwork.self_link
  nodes = var.numnodes
  node_type = var.node_type
  owner = var.owner
  default_gke = var.default_gke
}

module "k8s" {
  source = "./modules/kubernetes"
  # token = data.google_client_config.current.access_token
  cluster_endpoint = module.gke.cluster_endpoint
  # cluster_endpoint = "https://104.155.31.46"
  # client_certificate = module.gke.client_certificate
  cluster_namespace = "vault-cluster"
  # client_key = module.gke.client_key
  ca_certificate = module.gke.ca_certificate
  location = var.gcp_zone
  gcp_region = var.gcp_region
  gcp_project = var.gcp_project
  cluster_name = module.gke.cluster_name
  config_bucket = var.gcs_bucket
  # vault_repo ="hashicorp/vault-enterprise"
  # vault_version = "1.5.0"
  hostname = var.vault_hostname
  nodes = var.vault_nodes
  gcp_service_account = data.google_service_account.owner_project
  key_ring = var.key_ring
  crypto_key = var.crypto_key
  vault_cert = var.vault_cert
  vault_ca = var.vault_ca
  vault_key = var.vault_key
  tls = var.tls
}

resource "google_storage_bucket_object" "jx-requirements" {
  name   = "jx-requirements.yml"
  content = templatefile("${path.module}/templates/jx-requirements.yml.tpl",{
    gke_cluster = var.gke_cluster,
    owner = var.owner,
    github_org = "dcanadillas",
    zone = var.gcp_zone,
    project = var.gcp_project
  })
  bucket = var.gcs_bucket
}


# resource "local_file" "jx-requirements" {
#   content = templatefile("${path.module}/templates/jx-requirements.yml.tpl",{
#     gke_cluster = var.gke_cluster,
#     owner = var.owner,
#     github_org = "dcanadillas",
#     zone = var.gcp_zone,
#     project = var.gcp_project
#   })
#   filename = "${path.module}/jx-requirements-${var.gke_cluster}.yml"
# }
