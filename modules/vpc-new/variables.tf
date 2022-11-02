
variable "region" {
     type = string
}

variable "client" {
     type = string
}

variable "envt" { 
     type = string
}


variable  "N"  {
    type = string
}

variable "vpc_cidr" {
     type = string
}

variable "pub_subnet_list"{
     type = list(object({
      name = string
      cidr_block     = string
    }))

 }

variable "pvt_subnet_list"{
     type = list(object({
      name = string
      cidr_block     = string
    }))

 }

variable "s3-flowlog-bucket-name" {
}
