# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "terraform-project" {
  name     = "terraform"
  location = "East US"
  tags = {
    environment = "terraform"
  }
}

resource "azurerm_virtual_network" "terraform-network" {
  name                = "terraform-network"
  resource_group_name = azurerm_resource_group.terraform-project.name
  location            = azurerm_resource_group.terraform-project.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_subnet" "terraform-subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.terraform-project.name
  virtual_network_name = azurerm_virtual_network.terraform-network.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "terraform-nsg1" {
  name                = "terraform-nsg1"
  location            = azurerm_resource_group.terraform-project.location
  resource_group_name = azurerm_resource_group.terraform-project.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "98.183.186.202/32"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.terraform-subnet.id
  network_security_group_id = azurerm_network_security_group.terraform-nsg1.id
}

resource "azurerm_public_ip" "terraform-pip1" {
  name                = "terraform-pip1"
  resource_group_name = azurerm_resource_group.terraform-project.name
  location            = azurerm_resource_group.terraform-project.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_network_interface" "terraform-nic1" {
  name                = "terraform-nic1"
  location            = azurerm_resource_group.terraform-project.location
  resource_group_name = azurerm_resource_group.terraform-project.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform-pip1.id
  }

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_linux_virtual_machine" "linuxvm1" {
  name                  = "linuxvm1"
  resource_group_name   = azurerm_resource_group.terraform-project.name
  location              = azurerm_resource_group.terraform-project.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.terraform-nic1.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

