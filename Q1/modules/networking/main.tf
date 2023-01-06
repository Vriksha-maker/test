data "azurerm_resource_group" "rg" {
  name = var.rg-name
}

# resource for VNet creation
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-VNet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
}

# resource for Web Subnet creation
resource "azurerm_subnet" "web-subnet" {
  name                 = "${var.project_name}-web_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg-name
  address_prefixes     = [var.web_subnet_cidr]
}

# resource for application Subnet creation
resource "azurerm_subnet" "app-subnet" {
  name                 = "${var.project_name}-app_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg-name
  address_prefixes     = [var.app_subnet_cidr]
}

# resource for db Subnet creation
resource "azurerm_subnet" "db-subnet" {
  name                 = "${var.project_name}-db_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefixes     = [var.db_subnet_cidr]
}

# resource for Web nsg creation 
resource "azurerm_network_security_group" "web-nsg" {
  name                = "${var.project_name}-Web-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "rdpAllow"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "3389"
  }
}

# resource for App nsg creation 
resource "azurerm_network_security_group" "app-nsg" {
  name                = "${var.project_name}-App-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "AnyTrafficAllow"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "80"
  }

}
resource "azurerm_subnet_network_security_group_association" "web-nsg-subnet" {
  subnet_id                 = azurerm_subnet.web-subnet.id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}


# resource for Web1 NIC creation 
resource "azurerm_network_interface" "web1_nic" {
  name                = "${var.project_name}-iweb1-network-Inf"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "web1-webserver"
    subnet_id                     = azurerm_subnet.web-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip1.id
  }
}

# resource for Web2 NIC creation 
resource "azurerm_network_interface" "web2_nic" {
  name                = "${var.project_name}-web2-network-Inf"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "web2-webserver"
    subnet_id                     = azurerm_subnet.web-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip2.id
  }
}

# resource for App1 nic creation 
resource "azurerm_network_interface" "app1_nic" {
  name                = "${var.project_name}-app1-network-Inf"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "app1server"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource for App2 nic creation 
resource "azurerm_network_interface" "app2_nic" {
  name                = "${var.project_name}-app2-network-Inf"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "app2server"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource for web1_Public_IP creation 
resource "azurerm_public_ip" "public_ip1" {
  name                = "pub_ip1"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource for web2_Public_IP creation 
resource "azurerm_public_ip" "public_ip2" {
  name                = "pub_ip2"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource for Web1 VM creation 
resource "azurerm_windows_virtual_machine" "web1_vm" {
  name                = "${var.project_name}-web1"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.user
  admin_password      = var.password
  # zone                = var.zones[0]
  network_interface_ids = [azurerm_network_interface.web1_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# resource for Web2 VM creation 
resource "azurerm_windows_virtual_machine" "web2_vm" {
  name                = "${var.project_name}-web2"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.user
  admin_password      = var.password
  # zone                = var.zones[1]
  network_interface_ids = [azurerm_network_interface.web2_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# resource for App1 VM creation 
resource "azurerm_windows_virtual_machine" "app1_vm" {
  name                = "${var.project_name}-app1"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.user
  admin_password      = var.password
  # zone                = var.zones[0]
  network_interface_ids = [azurerm_network_interface.app1_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# resource for App2 VM creation 
resource "azurerm_windows_virtual_machine" "app2_vm" {
  name                = "${var.project_name}-app2"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.user
  admin_password      = var.password
  # zone                = var.zones[1]
  network_interface_ids = [azurerm_network_interface.app2_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}