data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Look up the Connect instance by alias when instance_id is not provided directly.
data "aws_connect_instance" "this" {
  count          = var.instance_id == null ? 1 : 0
  instance_alias = var.instance_alias
}
