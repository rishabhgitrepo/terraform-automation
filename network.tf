resource "aws_vpc" "this" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

# resource "aws_subnet" "this" {
#   for_each   = toset([ "192.168.0.0/27", "192.168.0.32/27", "192.168.0.64/27", "192.168.0.96/27", "192.168.0.128/27", "192.168.0.160/27" ])
#   vpc_id     = aws_vpc.this.id
#   cidr_block = each.value
#   tags = {
#     Name = "Main-${each.key}"
#   }
# }

#Creating subnets on different Azs
resource "aws_subnet" "subnets_az1" {
  for_each   = { "publicsubnet1_az1" : "192.168.0.0/27",  "privatesubnet1_az1" : "192.168.0.64/27", "privatesubnet2_az1" : "192.168.0.96/27" }
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = "us-east-1a" 
  tags = {
    Name = "Main-${each.key}"
  }
}

resource "aws_subnet" "subnets_az2" {
  for_each   = { "publicsubnet1_az2" : "192.168.0.32/27", "privatesubnet1_az2" : "192.168.0.128/27", "privatesubnet2_az2" : "192.168.0.160/27" }
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = "us-east-1b"
  tags = {
    Name = "Main-${each.key}"
  }
}


# resource "aws_subnet" "this" {
#   count      = length(var.cidr_subnet)
#   vpc_id     = aws_vpc.this.id
#   cidr_block = element(var.cidr_subnet, count.index)
#   tags = {
#     Name = "subnet-${count.index}"
#   }
# }

# variable "no_of_subnets" {
#   type        = number
#   description = "Number of subnets to be created"
#   default     = 6
# }

# variable "cidr_subnet" {
#   type        = list(string)
#   description = "(optional) List of CIDR range for subnet"
#   default     = ["192.168.0.0/27", "192.168.0.32/27", "192.168.0.64/27", "192.168.0.96/27", "192.168.0.128/27", "192.168.0.160/27"]
# }