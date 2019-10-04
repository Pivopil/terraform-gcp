variable "target_project_name" {}
variable "billing_account" {}
variable "org_id" {}
variable "region" {}
variable "target_project_id" {}
variable "tf_admin_project" {}

provider "google" {
  project = var.tf_admin_project
  region = var.region
}


resource "google_project" "project" {
  name            = var.target_project_name
  project_id      = var.target_project_id
  billing_account = var.billing_account
  org_id          = var.org_id
}

resource "google_project_services" "project" {
  project = google_project.project.project_id

  services = [
    "compute.googleapis.com",
  ]
}

output "project_id" {
  value = google_project.project.project_id
}
