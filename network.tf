resource "aws_vpc" "this" {
  cidr_block           = var.cidr_for_vpc
  instance_tenancy     = var.tenancy
  enable_dns_hostnames = var.dns_hostnames_enabled
  enable_dns_support   = var.dns_support_enabled
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name = "private_rt_${var.vpc_name}"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public_rt_${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw-${var.vpc_name}"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each                = { for index, az_name in slice(data.aws_availability_zones.this.names, 0, 2) : index => az_name }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_for_vpc, length(data.aws_availability_zones.this.names) > 3 ? 4 : 3, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet-${each.key}"
  }
}

resource "aws_subnet" "public_subnet" {
  for_each                = { for index, az_name in slice(data.aws_availability_zones.this.names, 0, 2) : index => az_name }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_for_vpc, length(data.aws_availability_zones.this.names) > 3 ? 4 : 3, each.key + length(data.aws_availability_zones.this.names))
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${each.key}"
  }
}

# Route table association Terraform

# resource "aws_route_table_association" "private_subnet_association" {
#   # for_each       = { for index, each_subnet in aws_subnet.private_subnet : index => each_subnet.id }
#   for_each       = toset([for each_subnet in aws_subnet.private_subnet : each_subnet.id])
#   subnet_id      = each.value
#   route_table_id = aws_default_route_table.this.id
# }

resource "aws_route_table_association" "private_subnet_association" {
  for_each       = { for index, each_subnet in aws_subnet.private_subnet : index => each_subnet.id }
  subnet_id      = each.value
  route_table_id = aws_default_route_table.this.id
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each       = { for index, each_subnet in aws_subnet.public_subnet : index => each_subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = element([for each_subnet in aws_subnet.public_subnet : each_subnet.id], 0)
  tags = {
    Name = "nat_gw_${var.vpc_name}"
  }
}

resource "aws_eip" "this" {
  domain = "vpc"
}

# resource "aws_subnet" "private_subnet" {
#   for_each          = { for index, az_name in data.aws_availability_zones.this.names : index => az_name }
#   vpc_id            = aws_vpc.this.id
#   cidr_block        = cidrsubnet(var.cidr_for_vpc, length(data.aws_availability_zones.this.names) > 4 ? 3 : 2, each.key)
#   availability_zone = each.value
#   tags = {
#     Name = "Private-subnet-${each.key}"
#   }
# }

# resource "aws_subnet" "public_subnet" {
#   for_each          = { for index, az_name in data.aws_availability_zones.this.names : index => az_name }
#   vpc_id            = aws_vpc.this.id
#   cidr_block        = cidrsubnet(var.cidr_for_vpc, length(data.aws_availability_zones.this.names) > 4 ? 3 : 2, each.key + length(data.aws_availability_zones.this.names))
#   availability_zone = each.value
#   tags = {
#     Name = "Public-subnet-${each.key}"
#   }
# }

# resource "aws_subnet" "this" {
#   for_each   = toset([ "192.168.0.0/27", "192.168.0.32/27", "192.168.0.64/27", "192.168.0.96/27", "192.168.0.128/27", "192.168.0.160/27" ])
#   vpc_id     = aws_vpc.this.id
#   cidr_block = each.value
#   tags = {
#     Name = "Main-${each.key}"
#   }
# }

#Creating subnets on different Azs
# resource "aws_subnet" "subnets_az1" {
#   for_each          = { "publicsubnet1_az1" : "192.168.0.0/27", "privatesubnet1_az1" : "192.168.0.64/27", "privatesubnet2_az1" : "192.168.0.96/27" }
#   vpc_id            = aws_vpc.this.id
#   cidr_block        = each.value
#   availability_zone = "us-east-1a"
#   tags = {
#     Name = "Main-${each.key}"
#   }
# }

# resource "aws_subnet" "subnets_az2" {
#   for_each          = { "publicsubnet1_az2" : "192.168.0.32/27", "privatesubnet1_az2" : "192.168.0.128/27", "privatesubnet2_az2" : "192.168.0.160/27" }
#   vpc_id            = aws_vpc.this.id
#   cidr_block        = each.value
#   availability_zone = "us-east-1b"
#   tags = {
#     Name = "Main-${each.key}"
#   }
# }


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
# }(var.cidr_for_vpc