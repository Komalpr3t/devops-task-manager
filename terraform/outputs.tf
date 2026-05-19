output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.k3s_node.public_ip
}

output "kubernetes_api_url" {
  description = "The URL to connect to the Kubernetes API"
  value       = "https://${aws_instance.k3s_node.public_ip}:6443"
}

output "ssh_connection_string" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.k3s_node.public_ip}"
}
