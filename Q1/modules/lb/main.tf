data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_public_ip" "lb_ip" {
  name                = "${var.project_name}-loadIP"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.project_name}-LoadBalancer"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend_ip"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "poolA" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "poolA"
}

resource "azurerm_lb_backend_address_pool_address" "backend-web1" {
  name                    = "backend-web1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.poolA.id
  virtual_network_id      = var.vnet_id
  ip_address              = var.web1_private_ip
}

resource "azurerm_lb_backend_address_pool_address" "backend-web2" {
  name                    = "backend-web2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.poolA.id
  virtual_network_id      = var.vnet_id
  ip_address              = var.web2_private_ip
}

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "ProveA"
  port            = 80
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend_ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.poolA.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
}