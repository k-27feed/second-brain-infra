output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.api.dns_name
}

output "security_group_id" {
  description = "ID of the API security group"
  value       = aws_security_group.api.id
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = aws_autoscaling_group.api.name
} 