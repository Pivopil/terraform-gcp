terraform {
 backend "gcs" {
   bucket  = "alex-terraform-admin"
   prefix  = "terraform/state"
 }
}
