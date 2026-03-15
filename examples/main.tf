module "network" {
  source = "../modules/az_network"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_config         = var.vnet_config
  subnet_configs      = var.subnet_configs
  nsg_configs         = var.nsg_configs
  route_table_configs = var.route_table_configs
  tags                = var.tags
}

module "virtual_machines" {
  source   = "../modules/az_virtual_machine"
  for_each = var.vm_configs

  vm_config           = each.value
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.network.subnets[each.value.subnet_key].id
  tags                = var.tags
}
