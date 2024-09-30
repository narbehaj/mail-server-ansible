terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
    namecom = {
      source  = "arthurpro/namecom"
      version = "1.0.3"
    }
  }
}

provider "namecom" {
  username = var.namecom_username
  token    = var.namecom_token
}

provider "openstack" {
  user_name   = var.username
  tenant_name = var.tenant
  password    = var.password
  auth_url    = var.auth_url
  region      = var.region
}
