locals {
  name_prefix                = "${var.product_name}-${var.account_id}"
  cloudquery_name            = "${local.name_prefix}-cloudquery-results"
  cloudquery_service_name    = "cloudquery"
  asset_inventory_admin_role = "secopsAssetInventoryCloudqueryRole"
}