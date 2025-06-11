variable "resource_group_name" {
  description = "The name of the resource group in which to create the Synapse workspace and resources."
  type        = string
}

variable "location" {
  description = "The Azure region where all resources will be deployed."
  type        = string
}

variable "synapse_workspace_name" {
  description = "The unique name to assign to the Synapse workspace."
  type        = string
}

variable "storage_data_lake_gen2_filesystem_id" {
  description = "The resource ID of the Azure Data Lake Gen2 filesystem to be used by the Synapse workspace."
  type        = string
}

variable "sql_administrator_login" {
  description = "The administrator login name for the Synapse SQL pool."
  type        = string
}

variable "sql_administrator_login_password" {
  description = "The administrator login password for the Synapse SQL pool."
  type        = string
  sensitive   = true
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
  description = "The type of managed identity assigned to the Synapse workspace. Possible values: 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  type        = string
  default     = "SystemAssigned"
}

variable "user_assigned_identity_ids" {
  description = "A list of user-assigned managed identity resource IDs to be assigned to the Synapse workspace."
  type        = list(string)
  default     = []
}

variable "aad_admin" {
  description = "An object specifying Azure Active Directory admin for the Synapse workspace. Format: { login = string, object_id = string, tenant_id = string }."
  type = object({
    login     = string
    object_id = string
    tenant_id = string
  })
  default = null
}

variable "customer_managed_key" {
  description = "An object specifying the customer-managed key configuration for encryption. Format: { key_vault_key_id = string, user_assigned_identity_id = string }."
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = string
  })
  default = null
}

variable "firewall_rules" {
  description = "A list of firewall rule objects to allow access to the Synapse workspace. Each object should have: { name = string, start_ip = string, end_ip = string }."
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
}

variable "private_endpoint_connections" {
  description = "A list of objects defining private endpoint connections. Each object should have: { name, private_link_service_id, subresource_name, is_manual_connection_approval }."
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
}

variable "sql_pool_sku_name" {
  description = "The SKU to use for the Synapse dedicated SQL pool (e.g., DW100c, DW200c)."
  type        = string
}

variable "sql_pool_create_mode" {
  description = "The create mode for the SQL pool. Possible values: 'Default', 'Recovery', or 'PointInTimeRestore'."
  type        = string
  default     = "Default"
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
