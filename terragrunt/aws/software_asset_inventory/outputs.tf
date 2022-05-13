output "software_inventory_load_balancer_dns" {
  description = "The DNS name of the Software Asset Inventory load balancer"
  value       = aws_lb.dependencytrack.dns_name
}
