provider "azurerm" {
  version = "~> 1.8.0"
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group}"
  location = "West Europe"

  tags {
    environment = "LFS458"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.trainer}_vnet"
  address_space       = ["${var.cidr}"]
  location            = "${azurerm_resource_group.resource_group.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  tags {
    environment = "LFS458"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.trainer}_subnet"
  resource_group_name  = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.cidr}"
}

# TODO can we iterate over lists? --> jinja or something else should be very easy?
module "student" {
  source                 = "modules/student_workspace"
  student                = "student"
  azurerm_resource_group = "${azurerm_resource_group.resource_group.name}"
  azurerm_subnet         = "${azurerm_subnet.subnet.name}"
  virtual_network_name   = "${azurerm_virtual_network.vnet.name}"
}
