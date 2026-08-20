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
    resource_group_name   = data.azurerm_resource_group.test_rg.name
    virtual_network_name  = azurerm_virtual_network.vnet_lab.name
    address_prefixes      = ["192.168.1.0/24"]

}

resource "azurerm_network_security_group" "nsg_lab" {
    name = "nsg_lab"
    location = data.azurerm_resource_group.test_rg.location
    resource_group_name = data.azurerm_resource_group.test_rg.name
    security_rule {
        name         = "Allow_ssh"
        priority     = 100
        direction    = "Inbound"
        access       = "Allow"
        protocol     = "Tcp"
        source_port_range      = "*"
        destination_port_range = "22"  
        source_address_prefix  = "187.255.40.219/32"
        destination_address_prefix = "*"

    }
        
        security_rule {
            name = "Allow_http"
            priority = 110
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = "80"
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
        public_ip_address_id = azurerm_public_ip.pub-ip.id
    }
}

resource "azurerm_public_ip" "pub-ip" {
    name = "pub-ip"
    location = data.azurerm_resource_group.test_rg.location
    resource_group_name = data.azurerm_resource_group.test_rg.name
    allocation_method = "Static"

}

resource "azurerm_linux_virtual_machine" "vmlab" {
    name = "vmlab"
    resource_group_name = data.azurerm_resource_group.test_rg.name 
    location = data.azurerm_resource_group.test_rg.location 
    size = "Standard_B1s"
    admin_username = "azureuser"
    network_interface_ids = [azurerm_network_interface.nic_lab.id]
    admin_ssh_key {
        username = "azureuser"
        public_key = file("~/.ssh/azure_vm_key.pub") 
 }


        os_disk {
            caching       = "ReadWrite"
            storage_account_type = "Standard_LRS" 
            }
            source_image_reference {
                publisher = "Canonical"
                offer   = "0001-com-ubuntu-server-jammy"
                sku   = "22_04-lts"
                version = "latest"
            }
}
