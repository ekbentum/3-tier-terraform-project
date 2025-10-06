
# Creating internet gateway ---------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

# Creating 2 public subnets ---------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_public_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_public_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1c"
  })
}

# Creating 2 Private subnets ---------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_private_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_private_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1c"
  })
}

# Creating 2 Database subnets ---------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_db_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[0]
  availability_zone = var.availability_zone[0]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_db_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[1]
  availability_zone = var.availability_zone[1]

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1c"
  })
}

# Creating Public Route Table ---------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}

# Creating Route Table Association for Public Subnets -----------------------------------------------------------
resource "aws_route_table_association" "public_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "public_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# Creating an Elastic IP for AZ 1a Nat Gate Way -----------------------------------------------------
 resource "aws_eip" "eip_az_1a" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1a"
  })
}

# Creating a Nat Gate Way for AZ 1a -----------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1a" {
  allocation_id = aws_eip.eip_az_1a.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1a, aws_subnet.apci_jupiter_public_subnet_az_1a]
}

# Creating Private Route Table for AZ 1b -----------------------------------------------------------
 resource "aws_route_table" "apci_jupiter_private_rt_az_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1a.id
  }
    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1a"
  }) 
}

# Creating Private Route  Table association for AZ 1a
resource "aws_route_table_association" "private_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

resource "aws_route_table_association" "db_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id 
}

# Creating an Elastic IP for AZ 1c Nat Gate Way -----------------------------------------------------
 resource "aws_eip" "eip_az_1c" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1c"
  })
}

# Creating a Nat Gate Way for AZ 1c -----------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1c" {
  allocation_id = aws_eip.eip_az_1c.id 
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1c.id 

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1c"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1c, aws_subnet.apci_jupiter_public_subnet_az_1c] 
}

# Creating Private Route Table for AZ 1c -----------------------------------------------------------
 resource "aws_route_table" "apci_jupiter_private_rt_az_1c" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1c.id 
  }
    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az-1c"
  }) 
}

# Creating Private Route  Table association for AZ 1c -------------------------------------------
resource "aws_route_table_association" "private_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}

resource "aws_route_table_association" "db_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id 
}