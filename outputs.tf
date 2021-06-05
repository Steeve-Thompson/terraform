output "app" {
  value = data.template_file.app.rendered
}
output "node_instance" {
  value = aws_instance.node.*.instance_type
}
output "ports" {
  value = local.master_ports
}
output "node_ports" {
  value = local.node_ports
}
