variable "resource_group_name" {
  description = "The name of the resource group in which to create the Synapse workspace and resources."
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "The Azure region where all resources will be deployed (e.g., eastus, westus2)."
  type        = string
  validation {
    condition     = length(var.location) > 0
    error_message = "location must not be empty."
  }
}

variable "synapse_workspace_name" {
  description = "The unique name to assign to the Synapse workspace."
  type        = string
  validation {
    condition     = length(var.synapse_workspace_name) > 0
    error_message = "synapse_workspace_name must not be empty."
  }
}

variable "storage_data_lake_gen2_filesystem_id" {
  description = "The resource ID of the Azure Data Lake Gen2 filesystem to be used by the Synapse workspace."
  type        = string
  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Storage/storageAccounts/.+/fileServices/default/filesystems/.+$", var.storage_data_lake_gen2_filesystem_id))
    error_message = "storage_data_lake_gen2_filesystem_id must be a valid Azure resource ID for a Data Lake Gen2 filesystem."
  }
}

variable "sql_administrator_login" {
  description = "The administrator login name for the Synapse SQL pool."
  type        = string
  validation {
    condition     = length(var.sql_administrator_login) > 0
    error_message = "sql_administrator_login must not be empty."
  }
}

variable "sql_administrator_login_password" {
  description = "The administrator login password for the Synapse SQL pool."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.sql_administrator_login_password) >= 8
    error_message = "sql_administrator_login_password must be at least 8 characters long."
  }
}

variable "managed_virtual_network_enabled" {
  description = "Specifies whether the workspace should have a managed virtual network enabled."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Determines if public network access to the Synapse workspace is allowed."
  type        = bool
  default     = true
}

variable "local_authentication_enabled" {
  description = "Indicates whether local authentication methods (SQL logins) are enabled."
  type        = bool
  default     = true
}

variable "identity_type" {
  description = <<EOT
The type of managed identity assigned to the Synapse workspace.
Possible values: "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned".
EOT
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "user_assigned_identity_ids" {
  description = "A list of user-assigned managed identity resource IDs to be assigned to the Synapse workspace."
  type        = list(string)
  default     = []
}

variable "aad_admin" {
  description = <<EOT
An object specifying Azure Active Directory admin for the Synapse workspace.
Format:
  {
    login     = string
    object_id = string
    tenant_id = string
  }
Example:
  {
    login     = "admin@contoso.com"
    object_id = "00000000-0000-0000-0000-000000000000"
    tenant_id = "11111111-1111-1111-1111-111111111111"
  }
EOT
  type = object({
    login     = string
    object_id = string
    tenant_id = string
  })
  default = null
}

variable "customer_managed_key" {
  description = <<EOT
An object specifying the customer-managed key configuration for encryption.
Format:
  {
    key_vault_key_id          = string
    user_assigned_identity_id = string
  }
Example:
  {
    key_vault_key_id          = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.KeyVault/vaults/xxx/keys/xxx",
    user_assigned_identity_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/xxx"
  }
EOT
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = string
  })
  default = null
}

variable "firewall_rules" {
  description = <<EOT
A list of firewall rule objects to allow access to the Synapse workspace.
Each object should have:
  {
    name     = string
    start_ip = string
    end_ip   = string
  }
Example:
  [
    {
      name     = "AllowHome"
      start_ip = "1.2.3.4"
      end_ip   = "1.2.3.4"
    }
  ]
EOT
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.firewall_rules :
      can(regex("^(?:\\d{1,3}\\.){3}\\d{1,3}$", rule.start_ip)) &&
      can(regex("^(?:\\d{1,3}\\.){3}\\d{1,3}$", rule.end_ip))
    ])
    error_message = "Each firewall rule must contain valid IPv4 addresses for start_ip and end_ip."
  }
}

variable "private_endpoint_connections" {
  description = <<EOT
A list of objects defining private endpoint connections.
Each object should have:
  {
    name                          = string
    private_link_service_id       = string
    subresource_name              = string
    is_manual_connection_approval = bool
  }
Example:
  [
    {
      name                          = "pe1"
      private_link_service_id       = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/privateLinkServices/xxx"
      subresource_name              = "dev"
      is_manual_connection_approval = false
    }
  ]
EOT
  type = list(object({
    name                          = string
    private_link_service_id       = string
    subresource_name              = string
    is_manual_connection_approval = bool
  }))
  default = []
}

variable "synapse_sql_pool_name" {
  description = "The name to assign to the Synapse dedicated SQL pool."
  type        = string
  validation {
    condition     = length(var.synapse_sql_pool_name) > 0
    error_message = "synapse_sql_pool_name must not be empty."
  }
}

variable "sql_pool_sku_name" {
  description = "The SKU to use for the Synapse dedicated SQL pool (e.g., DW100c, DW200c)."
  type        = string
  validation {
    condition     = length(var.sql_pool_sku_name) > 0
    error_message = "sql_pool_sku_name must not be empty."
  }
}

variable "sql_pool_create_mode" {
  description = "The create mode for the SQL pool. Possible values: 'Default', 'Recovery', or 'PointInTimeRestore'."
  type        = string
  default     = "Default"
  validation {
    condition     = contains(["Default", "Recovery", "PointInTimeRestore"], var.sql_pool_create_mode)
    error_message = "sql_pool_create_mode must be one of: Default, Recovery, PointInTimeRestore."
  }
}

variable "sql_pool_recovery_database_id" {
  description = "The resource ID of the SQL pool to recover from, if using recovery create mode."
  type        = string
  default     = null
}

variable "sql_pool_restore_point_in_time" {
  description = "The point-in-time to restore the SQL pool from, if using point-in-time restore mode."
  type        = string
  default     = null
}

variable "sql_pool_geo_backup_policy_enabled" {
  description = "Specifies whether geo-backup policy is enabled for the SQL pool."
  type        = bool
  default     = true
}

variable "sql_pool_encryption_enabled" {
  description = "Specifies whether transparent data encryption is enabled for the SQL pool."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
