provider "aws" {
  region     = "eu-west-2"
}

resource "aws_instance" "master" {
  count                   = var.Application_Name == "jenkins" ? 1 : var.Application_Name == "ansible" ? 1 : 0
  ami                     = var.master_aws_ami
  instance_type           = var.master_instance_type
  #availability_zone      = element(var.zone, count.index)
  key_name                = var.aws_keypair
  vpc_security_group_ids  = [aws_security_group.master_security_group.id]
  subnet_id               = aws_subnet.my-subnet-public-1.id
  #security_groups        = [ "${var.security_groups}" ]
  # subnet_id             = element(var.subnet_ids, count.index)
  user_data               = data.template_file.app.rendered
  root_block_device {
    volume_size           = var.master_instance_storage
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name              = "${var.Application_Name}-master"
    application_name  = var.Application_Name
    AutoStartStop     = "TRUE"
  }
}

resource "aws_instance" "node" {
  count = var.Application_Name == "jenkins" ? var.node_count : var.Application_Name == "ansible" ? var.node_count : 0
  ami = element(var.node_aws_ami, count.index)
  instance_type = element(var.node_instance_type, count.index)
  # availability_zone = element(var.zone, count.index)
  key_name = var.aws_keypair
  vpc_security_group_ids = [aws_security_group.node_security_group.id]
  subnet_id = aws_subnet.my-subnet-public-1.id
  #security_groups = [ "${var.security_groups}" ]
  #subnet_id     = element(var.subnet_ids, count.index)
  #user_data = data.template_file.app.rendered
  root_block_device {
    volume_size = element(var.node_instance_storage, count.index)
    volume_type = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "${var.Application_Name}-node-${count.index + 1}"
    application_name = var.Application_Name
    AutoStartStop = "TRUE"
  }
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink = "false"
  instance_tenancy = "default"

  tags = {
    Name = "${var.Application_Name}-vpc"
  }
}

resource "aws_subnet" "my-subnet-public-1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  #availability_zone = "eu-west-2"
  tags = {
    Name = "${var.Application_Name}-subnet-public-1"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.Application_Name}-internet-gateway"
  }
}

resource "aws_route_table" "my-public-crt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "${var.Application_Name}-public-route-table"
  }
}

resource "aws_route_table_association" "my-crta-public-subnet-1"{
  subnet_id = aws_subnet.my-subnet-public-1.id
  route_table_id = aws_route_table.my-public-crt.id
}

resource "aws_security_group" "master_security_group" {
  vpc_id = aws_vpc.my-vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = local.master_ports
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "${var.Application_Name}_master_security_group"
  }
}

resource "aws_security_group" "node_security_group" {
  vpc_id = aws_vpc.my-vpc.id


  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = local.node_ports
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "${var.Application_Name}_node_security_group"
  }
}