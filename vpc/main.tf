provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "my-s3-bucket-for-tfstate"
    key    = "quest/dev/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  
  tags = {
    Name = "my-igw"
  }
}

resource "aws_subnet" "public" {
  count = 3
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  availability_zone = element(var.availability_zones, count.index)
  
  tags = {
    Name = "my-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = 3
  cidr_block = "10.0.${count.index + 10}.0/24"
  vpc_id = aws_vpc.my-vpc.id
  map_public_ip_on_launch = false
  availability_zone = element(var.availability_zones, count.index)
  
  tags = {
    Name = "my-private-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id
  
    tags = {
      Name = "my-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my-vpc.id
   
   tags = {
     Name = "my-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = 3
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
   route_table_id = aws_route_table.public.id
   destination_cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.my-igw.id
}

resource "aws_route_table_association" "private" {
    count = 3
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}
