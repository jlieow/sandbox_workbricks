terraform {
  backend "gcs" {
    bucket  = "jlieow-tfstate-54321abcde"
    prefix  = "gcp_sandbox/databricks_workspace/standard_workspace/terraform.tfstate"
  }
}

provider "google" {
  project     = "fe-dev-sandbox"
  region      = "europe-west2"
	credentials = file("/Users/jerome.lieow/Documents/Secrets/fe-dev-sandbox-9923481d3082.json")
}

resource "google_compute_network" "vpc_network" {
  name = "jlieow-vpc-network"
}