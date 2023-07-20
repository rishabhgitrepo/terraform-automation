variable "cidr_for_vpc" {
  description = "Cidr range for VPC"
  type        = string
  # default     = "10.0.0.0/24"
}

variable "tenancy" {
  description = "Instance tenancy for instances launched in vpc"
  type        = string
  default     = "default"
}

variable "dns_hostnames_enabled" {
  description = "A boolean flag to enable/disable DNS hostname in the VPC"
  type        = bool
  default     = false
}

variable "dns_support_enabled" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "web_server_name" {
  type        = string
  description = "Name for the instance created as Web Server"
}

variable "key_name" {
  type        = string
  description = "key pair name"
  #default     = "deployer-key"
}

# variable "mykey" {
#   type = string
# }

variable "inbound_rules_web" {
  description = "ingress rule for security group of web server"
  type = list(object({
    port        = number
    description = string
    protocol    = string
  }))

  default = [{
    port        = 22
    description = "This is for ssh connection"
    protocol    = "tcp"
    },
    {
      port        = 80
      description = "this is for web hosting"
      protocol    = "tcp"
  }]
}
