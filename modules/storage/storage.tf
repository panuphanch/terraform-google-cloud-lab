resource "google_storage_bucket" "storage" {
  name          = var.name
  project       = var.project_id
  location      = var.location
  force_destroy = var.force_destroy
  uniform_bucket_level_access = true
}