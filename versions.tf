terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
  }
  required_version = "~> 0.13.0"
}
