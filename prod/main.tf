terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "sa1_test_eic_AbhinavJha"             
    storage_account_name = "diggerstorageaccount"     
    container_name       = "tfstate"                 
    key                  = "terraform/state"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "southeastasia"
  resource_group_name = "sa1_test_eic_AbhinavJha"

  tags = {
    Name = "terraform-vnet"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "subnetDelegation"
    service_delegation {
      name = "Microsoft.Network/virtualNetworks"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "terraform-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "terraform-nsg"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "terraform-nic"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  ip_configuration {
    name                          = "terraform-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "terraform-vm"
  resource_group_name   = azurerm_virtual_network.vnet.resource_group_name
  location              = azurerm_virtual_network.vnet.location
  size                  = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"
  disable_password_authentication = false

  admin_password = "Terraform@12345!" 

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name = "terraform-vm"
  }
}
