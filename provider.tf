terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.38"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {}
