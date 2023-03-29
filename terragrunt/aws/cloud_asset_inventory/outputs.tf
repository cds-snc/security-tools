output "cloud_asset_inventory_load_balancer_dns" {
  description = "The DNS name of the Cloud Asset Inventory load balancer"
  value       = aws_lb.cloudquery.dns_name
}
