
resource "aws_key_pair" "ssh_pub" {
  count      = var.ssh_key == null ? 0:1
  key_name   = var.ssh_key.name
  public_key = var.ssh_key.key
  tags       = var.tags
}
