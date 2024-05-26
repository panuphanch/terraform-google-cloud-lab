# Build Infrastructure with Terraform on Google Cloud: Challenge Lab

## Challenge scenario

You are a cloud engineer intern for a new startup. For your first project, your new boss has tasked you with creating infrastructure in a quick and efficient manner and generating a mechanism to keep track of it for future reference and changes. You have been directed to use Terraform to complete the project.

For this project, you will use Terraform to create, deploy, and keep track of infrastructure on the startup's preferred provider, Google Cloud. You will also need to import some mismanaged instances into your configuration and fix them.

In this lab, you will use Terraform to import and create multiple VM instances, a VPC network with two subnetworks, and a firewall rule for the VPC to allow connections between the two instances. You will also create a Cloud Storage bucket to host your remote backend.

### Task 1. Create the configuration files

Fill out the `variables.tf` files in the root directory and within the modules. Add three variables to each file: `region`, `zone`, and `project_id`. For their default values, use `us-east1`, `us-east1-d`, and your Google Cloud Project ID.

variables.tf

```YAML
variable "region" {
  description = "The region of the project"
  default     = "us-east1"
}

variable "zone" {
  description = "The zon of the project"
  default     = "us-east1-d"
}

variable "project_id" {
  description = "The project id of gcp"
  default     = "<fill in project id>"
}
```

main.tf

```YAML
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
```

Initialize Terraform.

```bash
terraform init
```

### Task 2. Import infrastructure

Add instances module reference into the `main.tf`

```YAML
module "instances" {
  source = "./modules/instances"
}
```

Write the [resource configurations](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) in the `instances.tf` file to match the pre-existing instances.

modules/instances/instances.tf

```YAML
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = <<-EOT
      #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = <<-EOT
      #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
```

Once you have written the resource configurations within the module, use the terraform import command to import them into your instances module.

```bash
terraform init
terraform import module.instances.google_compute_instance.tf-instance-1 <INSTANCE-1-ID>
terraform import module.instances.google_compute_instance.tf-instance-2 <INSTANCE-1-ID>
```

Apply your changes.

```bash
terraform apply
```

### Task 3. Configure a remote backend

Create a Cloud Storage bucket resource inside the storage module. For the bucket name, use `tf-bucket-656047`.

modules/storage/variables.tf

```YAML
variable "name" {
  description = "The name of the bucket."
  type        = string
}  

variable "project_id" {
  description = "The ID of the project to create the bucket in."
  type        = string
}  

variable "location" {
  description = "Location of bucket"
  type        = string
} 

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects."
  type        = bool
  default     = true
}
```

modules/storage/outputs.tf

```YAML
output "bucket" {
  description = "The created storage bucket"
  value       = google_storage_bucket.storage
}
```

modules/storage/storage.tf

```YAML
resource "google_storage_bucket" "storage" {
  name          = var.name
  project       = var.project_id
  location      = var.location
  force_destroy = var.force_destroy
  uniform_bucket_level_access = true
}
```

main.tf

```YAML
module "storage" {
  source        = "./modules/storage"

  name          = "<fill in bucket name>"
  project_id    = var.project_id
  location      = "US"
}
```

Apply the changes to create the bucket.

```bash
terraform apply
```

Configure this storage bucket as the remote backend inside the main.tf file.

```YAML
terraform {
  backend "gcs" {
    bucket = "<fill in bucket name>"
    prefix = "terraform/state"
  }
}
```

### Task 4. Modify and update infrastructure

Modify **tf-instance-1**, **tf-instance-2** resource to use an `e2-standard-2`

modules/instances/variables.tf

```YAML
variable "machine_type" {
  description = "type of instances"
  type = string
  default = "e2-micro"
}
```

modules/instances/instances.tf

```YAML
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type =  var.machine_type

  ...
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type =  var.machine_type

  ...
}

resource "google_compute_instance" "tf-instance-3" {
  name         = "<fill in instance name>"
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
```

main.tf

```YAML
module "instances" {
  source = "./modules/instances"
  machine_type = "e2-standard-2"
}
```

Initialize Terraform and apply your changes.

```bash
terraform init
terraform apply
```

### Task 5. Destroy resources

Destroy the third instance Instance Name by removing the resource from the configuration file. After removing it, initialize terraform and apply the changes.

### Task 6. Use a module from the Registry

Add [Network Module](https://registry.terraform.io/modules/terraform-google-modules/network/google/6.0.0) to `main.tf` file.

variables.tf

```YAML
variable "network_name" {
  description = "Name of VPC network"
  type = string
  default = "<fill in network name>"
}
```

main.tf

```YAML
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "6.0.0"  

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = var.region
    }
  ]
}
```

Initialize Terraform and run an apply to create the networks.

```bash
terraform init
terrafrom apply
```

#### Solve network module issues

Please note that if you got error `Error: Failed to query available provider packages` when `terraform init` you need to use `terraform init -upgrade` instead.

After that you may got error:

```PlainText
Error: Resource instance managed by newer provider version

The current state of module.storage.google_storage_bucket.storage was created by a newer provider version than is currently selected. Upgrade the google provider to work with this state.
```

You need to backup the state file in bucket and init again. Then you need to import all instances and storage again to sync everything.

```bash
terraform import module.instances.google_compute_instance.tf-instance-1 <INSTANCE-1-ID>
terraform import module.instances.google_compute_instance.tf-instance-2 <INSTANCE-1-ID>
terraform import module.storage.google_storage_bucket.storage <STORAGE-NAME>
```

Then init and apply.

#### Apply all subnets to instances

```YAML
resource "google_compute_instance" "tf-instance-1" {
  ...

  network_interface {
    network = "<fill in network name>"
    subnetwork = "subnet-01"
  }
  
  ...
}

  

resource "google_compute_instance" "tf-instance-2" {
  ...
  
  network_interface {
    network = "<fill in network name>"
    subnetwork = "subnet-02"
  }

  ...
}
```

### Task 7. Configure a firewall

Create a [firewall rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) resource in the `main.tf` file, and name it **tf-firewall**.

```YAML
resource "google_compute_firewall" "default" {
  name = "tf-firewall"
  network = "projects/<fill in project id>/global/networks/<fill in network name>"

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
```

Initialize Terraform and apply your changes.

Happy learning :tada:
