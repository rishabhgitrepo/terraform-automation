data "aws_availability_zones" "this" {
  all_availability_zones = true

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
# output "az_name" {
#   value = data.aws_availability_zones.this.names
# }