# Create a VPC
resource "aws_vpc" "justinshaw" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name        = "Justin Shaw Development"
    Environment = "Development"
  }
}

# Create a public subnet for each availability zone.
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones) # one public subnet per AZ
  vpc_id                  = aws_vpc.justinshaw.id
  cidr_block              = "10.1.${count.index * 2}.0/24" # Public subnets are even-numbered
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # Give all instances a public IP address.

  tags = {
    Name        = "Public Subnet (${var.availability_zones[count.index]})"
    Environment = "Development"
  }
}

# Create a private subnet for each availability zone.
resource "aws_subnet" "private" {
  count                   = length(var.availability_zones) # one private subnet per AZ
  vpc_id                  = aws_vpc.justinshaw.id
  cidr_block              = "10.1.${count.index * 2 + 1}.0/24" # Public subnets are odd-numbered
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false # Private instances do not get a public IP address.

  tags = {
    Name        = "Private Subnet (${var.availability_zones[count.index]})"
    Environment = "Development"
  }
}

# Create an internet gateway for the private subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.justinshaw.id # The VPC this Internet Gateway will attach to.

  tags = {
    Name        = "Main Internet Gateway"
    Environment = "Development"
  }
}

# Create a NAT gateway for the private subnets
resource "aws_nat_gateway" "private" {
  count      = length(var.availability_zones) # one nat gateway per private subnet
  subnet_id  = aws_subnet.public[count.index].id # The NAT Gateway attachs to the **public** subnet.
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "NAT Gateway (${var.availability_zones[count.index]})"
    Environment = "Development"
  }
}

# Create a route table for the private subnets
resource "aws_route_table" "private" {
  count  = length(var.availability_zones) # one route table per NAT gateway
  vpc_id = aws_vpc.justinshaw.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private[count.index].id
  }

  tags = {
    Name = "Private Routing Table (${var.availability_zones[count.index]})"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.justinshaw.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Routing Table"
  }
}

# Map each private subnet to its routing table
resource "aws_route_table_association" "private" {
  count  = length(var.availability_zones) # one route table per subnet
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Map each public subnet to the public routing table
resource "aws_route_table_association" "public" {
  count  = length(var.availability_zones) # one route table per subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}