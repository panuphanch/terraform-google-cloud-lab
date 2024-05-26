variable "machine_type" {
  description = "type of instances"
  type = string
  default = "e2-micro"
}

variable "network_name" {
  description = "Name of VPC network"
  type = string
}