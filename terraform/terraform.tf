terraform{

required_providers{

	aws={

	source = "hashicorp/aws"
	version = "6.22.1"
}

}
}
/////////////////////////////////////////////////////////////////

resource "aws_vpc" "k8s_cluster"{
	cidr_block="10.0.0.0/16"
	tags={
		Name="k8s_cluster_vpc"
	}
}

///////////////////////////////////////////////////////////////////

resource "aws_subnet" "private_subnet" {
	vpc_id = aws_vpc.k8s_cluster.id
	cidr_block = "10.0.1.0/24"
	tags = {
	  Name = "k8s_private_subnet"
	}
	}

  




////////////////////////////////////////////////////////////////////////////////



//private subnet


resource "aws_eip" "eip" {
	domain = "vpc"
	
  
}


resource "aws_nat_gateway" "k8s_nat_getway" {
	allocation_id = aws_eip.eip.id
	subnet_id = aws_subnet.public_subnet.id
	tags = {
	  Name = "k8s_nat_getway"
	}

	depends_on = [ aws_internet_gateway.k8s_internet_gateway ]
	
	}
  

resource "aws_route_table" "private_k8s_rout_table" {

vpc_id = aws_vpc.k8s_cluster.id


route {
	cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.k8s_nat_getway.id
}

tags = {
  Name = "private_k8s_rout_table"
}



}




resource "aws_route_table_association" "private_rout_table_association" {
	subnet_id = aws_subnet.private_subnet.id
	route_table_id = aws_route_table.private_k8s_rout_table.id
  
}


  





resource "aws_subnet" "public_subnet"{


vpc_id = aws_vpc.k8s_cluster.id
cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true   # IMPORTANT

tags = {
	Name = "k8s_public_subnet"
}





}

///////////////////////////////////////////////////////////////////////////////


resource "aws_internet_gateway" "k8s_internet_gateway"{

	vpc_id = aws_vpc.k8s_cluster.id

	tags={
		Name="k8s_cluster_iwg"
	}





}

//////////////////////////////////////////////////////////////////

resource "aws_route_table" "public_k8s_route_table"{
	vpc_id = aws_vpc.k8s_cluster.id
	route{
		cidr_block = "0.0.0.0/0"
		gateway_id= aws_internet_gateway.k8s_internet_gateway.id
	}

	tags={
		Name="public_k8s_rout_table"
	}
}

//////////////////////////////////////////////////////////////////////////////////
resource "aws_route_table_association" "connect_k8s_subnet_with_route_table" {
	subnet_id = aws_subnet.public_subnet.id
	route_table_id = aws_route_table.public_k8s_route_table.id
  
}

///////////////////////////////////////////////////////////////