# Define variables
variable "aws_region" {
  default = "us-east-1" # Update with your desired region
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16" # Update with your desired VPC CIDR block
}

# variable "public_subnet_cidr_blocks" {
#   default = ["10.0.1.0/24", "10.0.2.0/24"] # Update with your desired public subnet CIDR blocks
# }

# variable "private_subnet_cidr_blocks" {
#   default = ["10.0.10.0/24", "10.0.20.0/24"] # Update with your desired private subnet CIDR blocks
# }

# variable "db_subnet_cidr_blocks" {
#   default = ["10.0.100.0/24", "10.0.200.0/24"] # Update with your desired DB subnet CIDR blocks
# }

# data "aws_ami" "mew_ami" {
#   executable_users = ["self"]
#   most_recent      = true
#   name_regex       = "^myami-\\d{3}"
#   owners           = ["self"]

#   filter {
#     name   = "name"
#     values = ["myami-*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }
variable "instance_type" {
  type    = string
  default = "t2.micro"

}



# variable "aws_ami" {
#   default = "ami-06ca3ca175f37dd66"

# }
# variable "public_subnets" {
#   type = list(string)
# }

# variable "ports" {
#   type = list(number)
#   default = [ 22,80,443 ]
# }