terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
    backend "azurerm" {
        resource_group_name  = "cloud-shell-storage-westus"
        storage_account_name = "wordpressbackend822"
        container_name       = "tfstate"
        key                  = "enter key here"
    }

}