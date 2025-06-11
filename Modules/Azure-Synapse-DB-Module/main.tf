terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

resource "azurerm_synapse_workspace" "this" {
  name                                 = local.workspace_name
  resource_group_name                  = local.resource_group_name
  location                             = local.location
  storage_data_lake_gen2_filesystem_id = local.lake_fs_id
  sql_administrator_login              = local.admin_login
  sql_administrator_login_password     = local.admin_password
  managed_virtual_network_enabled      = local.managed_vnet_enabled
  public_network_access_enabled        = local.public_network_access
  local_authentication_enabled         = local.local_auth_enabled

  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []
    content {
      type         = local.identity_type
      identity_ids = local.user_identities
    }
  }

  dynamic "azuread_admin" {
    for_each = local.aad_admin != null ? [local.aad_admin] : []
    content {
      login     = azuread_admin.value.login
      object_id = azuread_admin.value.object_id
      tenant_id = azuread_admin.value.tenant_id
    }
  }

  dynamic "customer_managed_key" {
    for_each = local.cmk != null ? [local.cmk] : []
    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_synapse_firewall_rule" "this" {
  for_each             = { for rule in local.firewall_rules : rule.name => rule }
  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = each.value.start_ip
  end_ip_address       = each.value.end_ip
}

resource "azurerm_synapse_sql_pool" "this" {
  name                 = local.sql_pool_name
  resource_group_name  = local.resource_group_name
  location             = local.location
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  sku_name             = local.pool_sku_name
  create_mode          = local.pool_create_mode
  recovery_database_id = try(local.pool_restore_db_id, null)
  restore_point_in_time = try(local.pool_restore_time, null)
  geo_backup_policy_enabled = local.pool_geo_backup
  transparent_data_encryption_enabled = local.pool_encryption
  tags = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_synapse_private_link_hub" "this" {
  for_each            = { for ep in local.private_ep : ep.name => ep }
  name                = each.value.name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags
}
