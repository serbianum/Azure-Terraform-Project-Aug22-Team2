terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
  backend "azurerm" {
        resource_group_name  = "cloud-shell-storage-westus" #resource resource_group_name created manually 
        storage_account_name = "wordpressbackend822"     # created manually
        container_name       = "tfstate"
        key                  = "enter key here"
    }
}
