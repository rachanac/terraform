
# Create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-${var.client}-${var.envt}-${var.region}"
    env = var.envt
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


#Create internet gateway and attach it to vpc
resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.vpc.id
  tags      = {
    Name    = "igw-${var.client}-${var.envt}-${var.region}"
    env = var.envt
  }
}

########################################
# Create public subnet az1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public_subnet1-${var.client}-${var.envt}-${var.pub_stack}-${var.region}"
    env = var.envt
  }
}

# Create public subnet az2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public_subnet2-${var.client}-${var.envt}-${var.pub_stack}-${var.region}"
    env = var.envt
  }
}

# Create public subnet az3
resource "aws_subnet" "public_subnet3" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet3_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[2]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public_subnet2-${var.client}-${var.envt}-${var.pub_stack2}-${var.region}"
    env = var.envt
    }
}

# Create route table and add public route and associate rtbs
resource "aws_route_table" "public_rtb" {
  vpc_id       = aws_vpc.vpc.id
  tags       = {
    Name     = "public_rtb-${var.client}-${var.envt}-${var.region}"
    env = var.envt
    }
}
resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Associate public subnet az1 to "public route table"
resource "aws_route_table_association" "public_subnet1_rtb_association" {
  subnet_id           = aws_subnet.public_subnet1.id
  route_table_id      = aws_route_table.public_rtb.id
}

#Associate public subnet az2 to "public route table"
resource "aws_route_table_association" "public_subnet2_rtb_association" {
  subnet_id           = aws_subnet.public_subnet2.id
  route_table_id      = aws_route_table.public_rtb.id
}

#Associate public subnet az3 to "public route table"
resource "aws_route_table_association" "public_subnet3_rtb_association" {
  subnet_id           = aws_subnet.public_subnet3.id
  route_table_id      = aws_route_table.public_rtb.id
}
########################################

# Create  private  subnet az1
resource "aws_subnet" "private_subnet1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_subnet1_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private_subnet1-${var.client}-${var.envt}-${var.pvt_stack}-${var.region}"
    env = var.envt
    }
}

# create private  subnet az2

resource "aws_subnet" "private_subnet2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_subnet2_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private_subnet2-${var.client}-${var.envt}-${var.pvt_stack}-${var.region}"
    env = var.envt
    }
}
 
#Code for enabling NAT gateway 

resource "aws_eip" "ngw_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nat-${var.client}-${var.envt}-${var.region}"
    env = var.envt
    }
}

#Routing table for private subnet 
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private_rtb-${var.client}-${var.envt}-${var.region}"
    env = var.envt
    }
}

resource "aws_route" "private_ngw_route" {
  route_table_id         = aws_route_table.private_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "private_subnet1_rtb_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rtb.id
}
resource "aws_route_table_association" "private_subnet2_rtb_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rtb.id
}

#############
resource "aws_s3_bucket" "flowlogs" {
  bucket = var.s3-flowlog-bucket-name
} 
resource "aws_flow_log" "s3" {
  log_destination      = aws_s3_bucket.flowlogs.arn
  log_destination_type = "s3"
  traffic_type         = "REJECT"
  vpc_id               = aws_vpc.vpc.id
  tags = {
    Name = "${var.s3-flowlog-bucket-name}"
    env = var.envt
    }
}
