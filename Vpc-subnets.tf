# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Web-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet01"
  }
}
resource "aws_subnet" "public_02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet02"
  }
}
# Create private subnets
resource "aws_subnet" "private_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet01"
  }
}
resource "aws_subnet" "private_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private-subnet02"
  }
}
# Create DB subnets
resource "aws_subnet" "db_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Db-subnet01"
  }
}
resource "aws_subnet" "db_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Db-subnet02"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_01.id # Select a public subnet for the NAT gateway
}
resource "aws_eip" "eip" {
  domain = "vpc"
}

# Create internet gateway
resource "aws_internet_gateway" "Web_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Web-igw"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Web_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table_association" "public01_subnet_association" {
  subnet_id      = aws_subnet.public_01.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public02_subnet_association" {
  subnet_id      = aws_subnet.public_02.id
  route_table_id = aws_route_table.public_route_table.id
}


# Create route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-route-table"
  }
}
resource "aws_route_table_association" "private_01_subnet_association" {
  subnet_id      = aws_subnet.private_01.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "private_02_subnet_association" {
  subnet_id      = aws_subnet.private_02.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "db_01_subnet_association" {
  subnet_id      = aws_subnet.db_01.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "db_02_subnet_association" {
  subnet_id      = aws_subnet.db_02.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create database subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.db_01.id, aws_subnet.db_02.id]
}