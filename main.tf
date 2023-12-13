
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.84.0"
    }
  }
}

provider "azurerm" {
  subscription_id  = "f4fdd018-0692-439e-9caf-6eaf7a41ef72"
  client_id        = "96b30fd3-2bb9-4c3c-8845-701910c46c24"
  client_secret    = "EL78Q~mFq-VVIS9gicNS514Zh~O9x81s5E3XtaPk"
  tenant_id        = "cfc69c3e-1a4e-4da9-9df3-ab2981ce811d"
  features { }
}

resource "azurerm_resource_group" "example" {
  name     = "myResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "myNIC"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "myVM"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  network_interface_ids = [azurerm_network_interface.example.id]

  size = "Standard_DS1_v2"

  admin_username = "adminuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C://Users//rishi//OneDrive//Documents//terraform//AZURE//mykey.pub") # Replace with the path to your SSH public key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
