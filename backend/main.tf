terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "storage_account_name" {
  type    = string
  default = "diggerstorageaccount"
}

variable "container_name" {
  type    = string
  default = "tfstate"
}

variable "lock_table_name" {
  type    = string
  default = "digger-lock-table"
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = "sa1_test_eic_AbhinavJha" 
  location                 = "southeastasia"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_cosmosdb_account" "example" {
  name                = "diggercosmosdbaccount"
  location            = "southeastasia"
  resource_group_name = "sa1_test_eic_AbhinavJha" 
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "southeastasia"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "lock_table_database" {
  name                = "tfstatelockdb"
  resource_group_name = "sa1_test_eic_AbhinavJha" 
  account_name        = azurerm_cosmosdb_account.example.name
}
