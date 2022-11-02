
output "region" {
    value = var.region
}   

output "client" {
    value = var.client
}  

output "envt" {
    value = var.envt
} 

   

output "vpc_id" {
    value = aws_vpc.vpc.id
}
output "vpc_cidr" {
    value = var.vpc_cidr
} 

####

output "igw" {
    value = aws_internet_gateway.igw.id
} 


output "public_rtb" {
    value = aws_route_table.public_rtb.id
}


####
/*
output "ngw" {
    value = aws_nat_gateway.ngw.id
}

output "private_subnet1" {
    value = aws_subnet.private_subnet2.id
} 
output "private_subnet1_cidr" {
    value = var.private_subnet2_cidr
} 
output "private_subnet2" {
    value = aws_subnet.private_subnet2.id
} 
output "private_subnet2_cidr" {
    value = var.private_subnet2_cidr
} 
*/