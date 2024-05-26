resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type =  var.machine_type

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }  

  network_interface {
    network = var.network_name
    subnetwork = "subnet-01"
    access_config {
    }
  }  

  metadata_startup_script = <<-EOT
      #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type =  var.machine_type

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }  

  network_interface {
    network = var.network_name
    subnetwork = "subnet-02"
    access_config {
    }
  }  

  metadata_startup_script = <<-EOT
      #!/bin/bash
    EOT
  allow_stopping_for_update = true
}