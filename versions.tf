terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  required_version = ">= 0.14"
}
