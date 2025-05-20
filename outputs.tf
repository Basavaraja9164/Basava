output "blue_alb_dns" {
  value = module.blue_asg.alb_dns
}

output "green_alb_dns" {
  value = module.green_asg.alb_dns
}
