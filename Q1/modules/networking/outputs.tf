output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "rg_location" {
  value = data.azurerm_resource_group.rg.location
}

output "virtualnetwork_id" {
    value = azurerm_virtual_network.vnet.id
}

output "web_subet_id" {
  value = azurerm_subnet.web-subnet.id
}

output "app_subet_id" {
  value = azurerm_subnet.app-subnet.id
}

output "db_subet_id" {
  value = azurerm_subnet.db-subnet.id
}

output "web_nsg_id" {
  value = azurerm_network_security_group.web-nsg.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.web-nsg.id
}

output "web1_private_ip" {
  value = azurerm_network_interface.web1_nic.private_ip_address
}

output "web2_private_ip" {
  value = azurerm_network_interface.web2_nic.private_ip_address
}

output "web1_vm" {
  value = azurerm_windows_virtual_machine.web1_vm
}

output "web2_vm" {
  value = azurerm_windows_virtual_machine.web2_vm
}

output "app1_vm" {
  value = azurerm_windows_virtual_machine.app1_vm
}

output "app2_vm" {
  value = azurerm_windows_virtual_machine.app2_vm
}