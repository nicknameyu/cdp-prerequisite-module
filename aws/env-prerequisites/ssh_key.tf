
resource "aws_key_pair" "ssh_pub" {
  count      = var.ssh_key_name == "" ? 0:1
  key_name   = var.ssh_key_name
  public_key = var.ssh_key == null ? file("~/.ssh/id_rsa.pub") : var.ssh_key
  tags       = var.tags
}

output "ssh_key_name" {
  value = var.ssh_key_name == "" ? null : aws_key_pair.ssh_pub[0].key_name
}