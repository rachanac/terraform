
provider "aws" {
  profile = "${var.management_profile}"
  region  = "${var.mgmt_region}"
}

 ####################

 

data "aws_caller_identity" "mgmt_acct" {}


data "aws_vpc" "management" {
    id = "${var.management_vpc_id}"
}



# Requester's side of the connection.
resource "aws_vpc_peering_connection" "management" {
  vpc_id        =  var.management_vpc_id
  peer_vpc_id   =  var.accepter_vpc_id
  peer_owner_id =  var.accepter_acct_id 
  peer_region   =  var.accepter_region
  tags = {
    Name = "${var.prefix}_${var.accepter_acct_id}_${var.accepter_vpc_id}"
  }
}

#Add route rule in the route tables of management acct in which bastion resides
resource "aws_route" "management" {
  route_table_id            = "${var.bastion_routetable_id}"
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = "${aws_vpc_peering_connection.management.id}"
} 

 