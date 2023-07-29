# Output the load balancer DNS name
output "load_balancer_dns_name" {
  value = aws_lb.web_lb.dns_name
}