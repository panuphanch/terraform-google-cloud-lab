variable "name" {
  description = "The name of the bucket."
  type        = string
}  

variable "project_id" {
  description = "The ID of the project to create the bucket in."
  type        = string
}  

variable "location" {
  description = "Location of bucket"
  type        = string
  default     = "US"
} 

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects."
  type        = bool
  default     = true
}