# Configure the GCP provider
provider "google" {
  project = "css-ytd-2024"  # Replace with your GCP project ID
  region  = "europe-north1"         # Replace with your GCP region
  zone    = "europe-north1-a"           # Replace with your GCP zone
}

# Define input variables for bucket and folder names
variable "bucket_name" {
  description = "The name of the GCP storage bucket"
  type        = string
}

variable "folder_name" {
  description = "The name of the folder to create inside the bucket"
  type        = string
}

# Create a storage bucket
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location       = "EU"  # You can specify a different location if needed
  uniform_bucket_level_access = true
}

# Create an empty folder inside the bucket
resource "google_storage_bucket_object" "folder" {
  name   = var.folder_name  # Note the trailing slash to indicate a folder
  bucket = google_storage_bucket.bucket.name
  content = "Not really a directory, but it's empty."
#  source = ""
#  source = ""  # Empty source to create a folder
}

# Output the bucket name
output "bucket_name" {
  description = "The name of the GCP storage bucket"
  value       = google_storage_bucket.bucket.name
}

# Output the folder name
output "folder_name" {
  description = "The name of the folder inside the bucket"
  value       = google_storage_bucket_object.folder.name
}
