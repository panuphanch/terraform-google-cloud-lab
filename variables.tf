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
  default     = "qwiklabs-gcp-03-c7d436cca5f6"
}

variable "network_name" {
  description = "Name of VPC network"
  type = string
  default = "tf-vpc-411374"
}