terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote state in Azure Blob Storage so GitHub Actions runners share one state.
  # Values are supplied at "terraform init" time with -backend-config
  # (see .github/workflows/00-infrastructure.yml and infra/bootstrap.sh).
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
