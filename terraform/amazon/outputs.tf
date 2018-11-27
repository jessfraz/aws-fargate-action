output "alb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

output "container_definitions" {
  value = "${local.container_definitions}"
}
