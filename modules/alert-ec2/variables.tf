

variable "prefix" {
  description = ""
  type        = string
}

variable "region" {
  description = ""
  type        = string
}

variable "sns_arn" {
  description = ""
  type        = string
}

variable "instance_id" {
  description = ""
  type        = string
}

 
variable "instance_devices" {
  description = ""
  type = list(object({
      device    = string
      path      = string
      fstype    = string
    }))
  default     = [
    {
      device    = "xvda1"
      path      = "/"
      fstype    = "ext4"
     },
  ]
}

 
