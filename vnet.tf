data "azurerm_resource_group" "test_rg" {
   name = "test_rg"
}


resource "azurerm_virtual_network" "vnet_lab" {
    name = "vnet_lab"
    location = data.azurerm_resource_group.test_rg.location
    resource_group_name = data.azurerm_resource_group.test_rg.name
    address_space = ["192.168.0.0/16"]


}

resource "azurerm_subnet" "subnet_lab" {
    name = "subnet_lab"
    resource_group_name = data.azurerm_resource_group.test_rg.name
    virtual_network_name = azurerm_virtual_network.vnet_lab.name
    address_prefixes = ["192.168.1.0/24"]


 
}

resource "azurerm_network_security_group" "nsg_lab" {
    name = "nsg_lab"
    location = data.azurerm_resource_group.test_rg.location
    resource_group_name = data.azurerm_resource_group.test_rg.name
    security_rule {
        name = "Allow_ssh"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"  
        source_address_prefix = "*"
        destination_address_prefix = "*"
    

          }


}
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
    subnet_id = azurerm_subnet.subnet_lab.id
    network_security_group_id = azurerm_network_security_group.nsg_lab.id

}
resource "azurerm_network_interface" "nic_lab" {
    name = "nic_lab" 
    location = data.azurerm_resource_group.test_rg.location 
    resource_group_name = data.azurerm_resource_group.test_rg.name
    ip_configuration {
        name = "ipconfig1"
        subnet_id = azurerm_subnet.subnet_lab.id
        private_ip_address_allocation = "Dynamic"
    }
}
