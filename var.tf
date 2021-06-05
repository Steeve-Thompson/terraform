variable "Application_Name" {
  type = string
}

variable "aws_keypair" {
  type = string
}

##MASTER

variable "master_instance_type" {
  type = string
}

variable "master_instance_storage" {
  type = number

}

//variable "zone" {
//  default = ["eu-west-2a","eu-west-2b"]
//}

variable "master_aws_ami" {
  type = string
}

variable "master_ports" {
  type = list(number)
}
locals {
  master_ports = var.master_ports
}

##NODE

variable "node_instance_type" {
  type = list(string)
}
variable "node_instance_storage" {
  type = list(number)
}

variable "node_aws_ami" {
  type = list(string)
}

variable "node_count" {
  type = number
}

variable "node_ports" {
  type = list(number)
}
locals {
  node_ports = var.node_ports
}
