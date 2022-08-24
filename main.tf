# Required Google APIs

locals {
  googleapis = ["bigtable.googleapis.com", "cloudkms.googleapis.com", ]
}

resource "google_project_service" "bigtable" {
  for_each           = toset(local.googleapis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_kms_key_ring" "example-keyring03" {
  name     = "keyring-example603"
  location = "us-central1"
  depends_on = [
    google_project_service.bigtable
  ]
}

resource "google_kms_crypto_key" "bt_key03" {
  name     = "key03"
  key_ring = google_kms_key_ring.example-keyring03.id
}

resource "google_kms_key_ring" "example-keyring04" {
  name     = "keyring-example604"
  location = "us-east1"
  depends_on = [
    google_project_service.bigtable
  ]
}

resource "google_kms_crypto_key" "bt_key04" {
  name     = "key04"
  key_ring = google_kms_key_ring.example-keyring04.id
}


# Deployment to PROD need to have HA support deploying cluster in different zones of regions.

resource "google_bigtable_instance" "bt_prod_instance03" {
  name                = "bt-wf-instance"
  deletion_protection = false

  cluster {
    cluster_id   = "bt-instance-cluster-central"
    storage_type = "HDD"
    zone         = "us-central1-b"
    kms_key_name = google_kms_crypto_key.bt_key03.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  cluster {
    cluster_id   = "bt-instance-cluster-east"
    storage_type = "HDD"
    zone         = "us-east1-b"
    kms_key_name = google_kms_crypto_key.bt_key04.id
    autoscaling_config {
      min_nodes  = 1
      max_nodes  = 5
      cpu_target = 50
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}


data "google_compute_zones" "zones" {

}

resource "google_bigtable_instance" "bt_prod_instance04" {
  name                = "bt-wf-multi-zone"
  deletion_protection = false

  dynamic "cluster" {
    for_each = slice(data.google_compute_zones.zones.names, 0, var.num_zones)
    content {
      cluster_id   = "bt-instance-cluster03"
      storage_type = "HDD"
      zone         = cluster.value
      kms_key_name = google_kms_crypto_key.bt_key03.id
      autoscaling_config {
        min_nodes  = 1
        max_nodes  = 1
        cpu_target = 50
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}