
variable "prefix" {
  description = ""
  type        = string
  default     = "vpc_peering_to"
}

variable "mgmt_region" {
  description = ""
  type        = string
}

variable "management_profile" {
  description = ""
  type        = string
}

variable "management_vpc_id" {
  description = ""
  type        = string
}

variable "bastion_routetable_id" {
  description = ""
  type        = string
}

variable "accepter_region" {
  description = ""
  type        = string
}

variable "accepter_profile" {
  description = ""
  type        = string
}

variable "accepter_vpc_id" {
  description = ""
  type        = string
}



