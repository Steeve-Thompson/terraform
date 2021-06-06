//resource "tls_private_key" "private_key" {
//  algorithm = "RSA"
//  rsa_bits = 4096
//}
//resource "aws_key_pair" "keys" {
//  key_name = var.aws_keypair
//  public_key = tls_private_key.private_key.public_key_openssh
//}
//
//resource "aws_ssm_parameter" "private_key_ssm" {
//  name = "${var.aws_keypair}-private-key"
//  type = "SecureString"
//  value = tls_private_key.private_key.private_key_pem
//}
//resource "aws_ssm_parameter" "public_key_ssm" {
//  name = "${var.aws_keypair}-public-key"
//  type = "SecureString"
//  value = tls_private_key.private_key.public_key_pem
//}
//resource "aws_ssm_parameter" "public_key_openssh_ssm" {
//  name = "${var.aws_keypair}-public-key-openssh"
//  type = "SecureString"
//  value = tls_private_key.private_key.public_key_openssh
//}