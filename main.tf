terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "data_corruption_in_postgresql_database" {
  source    = "./modules/data_corruption_in_postgresql_database"

  providers = {
    shoreline = shoreline
  }
}