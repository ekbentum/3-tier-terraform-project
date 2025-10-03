# Creating Security Group for Bastion Host --------------------------------------------------------------
resource "aws_security_group" "apci_jupiter_bastion_sg" {
  name        = "apci-jupiter-bastion-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion_host_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id 
  cidr_ipv4         = "0.0.0.0/0" 
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ssh_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Creating Bastion Host ---------------------------------------------------------------------------------------
resource "aws_instance" "apci_jupiter_bastion_host" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = true 
  subnet_id = var.apci_jupiter_public_subnet_az_1a
  security_groups = [aws_security_group.apci_jupiter_bastion_sg.id]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host"
  }) 
}

# Creating Security Group for private servers ----------------------------------------------------------------------------------
resource "aws_security_group" "apci_jupiter_private_server_sg" {
  name        = "private_server-sg"
  description = "Allow SSH traffic from bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "privare_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion_host" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id 
  referenced_security_group_id =  aws_security_group.apci_jupiter_bastion_sg.id 
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_bastion_ssh_traffic_ipv4" {
  security_group_id = aws_security_group.apci_jupiter_private_server_sg.id 
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Creating Private Server for AZ 1a ----------------------------------------------------------------------------
resource "aws_instance" "apci_jupiter_private_server_az_1a" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = false  
  subnet_id = var.apci_jupiter_private_server_az_1a
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server_az-1a"
  }) 
}

# Creating Private Server for AX 1c ------------------------------------------------------------------------------
resource "aws_instance" "apci_jupiter_private_server_az_1c" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = false  
  subnet_id = var.apci_jupiter_private_subnet_az_1c 
  security_groups = [aws_security_group.apci_jupiter_private_server_sg.id]

    tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server_az-1c"
  }) 
}