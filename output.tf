# ALB DNS NAME
output "alb-dns-name" {
  value = aws_lb.ipstack-alb.dns_name
}