output "monitoring_server_public_ip" {
    value = aws_instance.monitoring_server.public_ip
}

output "app_server_private_ip" {
    value = aws_instance.app_server.private_ip
}

output "app_server_public_ip" {
    value = aws_instance.app_server.public_ip
}