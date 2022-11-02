
provider "aws" {
  profile = "${var.management_profile}"
  region  = "${var.mgmt_region}"
}


provider "aws" {
  alias = "accepter"
  region  = "${var.accepter_region}"
  profile = "${var.accepter_profile}"
}
 ####################

data "aws_vpc" "accepter" {
    provider = aws.accepter
    id = "${var.accepter_vpc_id}"
}

data "aws_caller_identity" "mgmt_acct" {}

data "aws_vpc" "management" {
    id = "${var.management_vpc_id}"
}

locals {
  accepter_account_id = "${element(split(":", data.aws_vpc.accepter.arn), 4)}"
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "management" {
  vpc_id = "${var.management_vpc_id}"
  peer_vpc_id   = "${data.aws_vpc.accepter.id}"
  peer_owner_id = "${local.accepter_account_id}"  
  peer_region   = "${var.accepter_region}"
  tags = {
    Name = "${var.prefix}_${local.accepter_account_id}_${var.accepter_vpc_id}"
  }
}

#Add route rule in the route tables of management acct in which bastion resides
resource "aws_route" "management" {
  route_table_id            = "${var.bastion_routetable_id}"
  destination_cidr_block    = "${data.aws_vpc.accepter.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.management.id}"
} 



#------------------- At acceptor side -------------#
# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = "${aws_vpc_peering_connection.management.id}"
  auto_accept               = true

  tags = {
    Name = "${var.prefix}_${data.aws_caller_identity.mgmt_acct.account_id}_${var.management_vpc_id}"
  }
}

#To get route tables list in accepter  acct
data "aws_route_tables" "accepter" {
  provider = aws.accepter
  vpc_id = "${data.aws_vpc.accepter.id}"
}

#Add route rule in the route tables of accepter acct
resource "aws_route" "accepter" {
  provider = aws.accepter
  count = "${length(data.aws_route_tables.accepter.ids)}"
  route_table_id            = "${data.aws_route_tables.accepter.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.management.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.management.id}"
} 

 


/*
#To get route tables list from management acct
data "aws_route_tables" "management" {
  vpc_id = "${var.management_vpc_id}"
}

#Add route rule in the route tables of management acct
resource "aws_route" "management" {
  count = "${length(data.aws_route_tables.management.ids)}"
  route_table_id            = "${data.aws_route_tables.management.ids[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.accepter.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.management.id}"
}   
*/