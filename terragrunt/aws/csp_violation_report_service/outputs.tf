output "csp_violation_report_service_load_balancer_dns" {
  description = "The DNS name of the CSP Violation Report Service load balancer"
  value       = aws_lb.csp_reports.dns_name
}
