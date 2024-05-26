terraform {
  backend "gcs" {
    bucket = "tf-bucket-656047"
    prefix = "terraform/state"
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source = "./modules/instances"
  machine_type = "e2-standard-2"
  network_name = var.network_name
}

module "storage" {
  source = "./modules/storage"

  name        = "tf-bucket-656047"
  project_id  = var.project_id
  location    = "US"
}

module "vpc" {
  source = "terraform-google-modules/network/google"
  version = "6.0.0"

  project_id = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name = "subnet-01"
      subnet_ip = "10.10.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name = "subnet-02"
      subnet_ip = "10.10.20.0/24"
      subnet_region = var.region
    }
  ]
}

resource "google_compute_firewall" "default" {
  name = "tf-firewall"
  network = "projects/qwiklabs-gcp-03-c7d436cca5f6/global/networks/tf-vpc-411374"

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}