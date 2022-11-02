

/* A public subnet instance
always  associate_public_ip_address  = true
*/

resource "aws_instance" "stack_web" {
  
  ami                          = var.instance_ami
  instance_type                = var.instance_type
  subnet_id                    = var.instance_subnet
  vpc_security_group_ids       = [var.instance_sg_id]
  iam_instance_profile         = var.instance_profile
  key_name                     = var.instance_key
  associate_public_ip_address  = true
  disable_api_termination      = true
  tags                         = "${merge(var.instance_tags)}"
  
  root_block_device {
    volume_type           = var.instance_volumetype
    volume_size           = var.instance_volumesize
    delete_on_termination = "true"
    encrypted = true
    
  }
}

# Create the Security Group
resource "aws_security_group" "sgrp_stack_web" {

  vpc_id      = var.vpc_id
  name        = "sgrp-${var.client}-${var.envt}-web-${var.region}"
  description = "sgrp-${var.client}-${var.envt}-web-${var.region}"
  tags        = "${merge(var.sgrp_tags)}"

  }
  
resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.prod.id

}

resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = [var.egress_rules[count.index].cidr_block]
  description       = var.egress_rules[count.index].description
  security_group_id = aws_security_group.prod.id

}

# Create alarms
module "alert_ec2" {
    source                = "../modules/alert_ec2"
    region                = var.region
    client                = var.client
    envt                  = var.envt
}