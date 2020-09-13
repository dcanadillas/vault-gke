# Keyrings in GCP cannot be deleted, so we generate a random number for the name
resource "random_id" "gcp_kms_key" {
  byte_length = 6
  prefix      = "${var.crypto_key}-"
}

data "google_kms_key_ring" "key_ring" {
  name     = var.key_ring
  location = var.gcp_region
}

locals {
   depends_on = [ google_kms_key_ring.key_ring, data.google_kms_key_ring.key_ring ]
   gcp_keyring = data.google_kms_key_ring.key_ring.name != null ? data.google_kms_key_ring.key_ring.self_link : google_kms_key_ring.key_ring[0].self_link
}

# Create a KMS key ring
resource "google_kms_key_ring" "key_ring" {
   count = data.google_kms_key_ring.key_ring.name != null ? 0 : 1
   project  = var.gcp_project
   name     = var.key_ring
   location = var.gcp_region
}

# Create a crypto key for the key ring
resource "google_kms_crypto_key" "crypto_key" {
   name            = random_id.gcp_kms_key.dec
   key_ring        = local.gcp_keyring
   rotation_period = "100000s"
}
# Add the service account to the Keyring
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  depends_on = [ google_kms_key_ring.key_ring ]
  #key_ring_id = "${google_kms_key_ring.key_ring.id}"
  key_ring_id = "${var.gcp_project}/${var.gcp_region}/${var.key_ring}"
  role = "roles/owner"

  members = [
    # "serviceAccount:${data.google_service_account.owner_project.email}",
    "serviceAccount:${var.gcp_service_account.email}"
  ]
}