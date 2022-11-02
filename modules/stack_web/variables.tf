

variable "region" {
}

variable "client" {
}

variable "instance_ami" {
}

variable "instance_type" {
}

variable "instance_subnet" {
}

variable "instance_sg_id" {
}
variable "instance_key" {
}
variable "instance_profile" {
}
variable "instance_tags" {
    type        = map(string)
    description = "Instance Tags"
}
variable "instance_volumetype" {
}
variable "instance_volumesize" {
}


##############sec grp 
variable "vpc_id" {
}
variable "sgrp_tags" {
    type        = map(string)
    description = "Security group Tags"
}

variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
}

variable "egress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
    default     = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
          description = "egress-prod"
        },
        
    ]
}

###########alerts
