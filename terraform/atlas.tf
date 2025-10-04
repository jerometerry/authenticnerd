# terraform/atlas.tf

variable "atlas_project_id" {
  description = "Your MongoDB Atlas Project ID."
  type        = string
}

data "mongodbatlas_network_containers" "main" {
  project_id    = var.atlas_project_id
  provider_name = "AWS"
}

# Initiate peering from Atlas to AWS
resource "mongodbatlas_network_peering" "peer" {  
  project_id   = var.atlas_project_id
  provider_name = "AWS"

  container_id = data.mongodbatlas_network_containers.main.results[0].id
  
  accepter_region_name   = data.aws_region.current.id
  aws_account_id         = data.aws_caller_identity.current.account_id
  vpc_id                 = aws_vpc.main.id
  route_table_cidr_block = aws_vpc.main.cidr_block
}

# Accept the peering connection from the AWS side
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.peer.connection_id
  auto_accept               = true
}

# Add a route to the AWS VPC route table to send traffic to Atlas
resource "aws_route" "to_atlas" {
  route_table_id            = aws_vpc.main.main_route_table_id
  destination_cidr_block    = mongodbatlas_network_peering.peer.atlas_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  # Explicitly wait for the peering connection to be accepted before creating the route
  depends_on = [aws_vpc_peering_connection_accepter.peer]
}

resource "mongodbatlas_project_ip_access_list" "vpc_access" {
  project_id = var.atlas_project_id
  cidr_block = aws_vpc.main.cidr_block
  comment    = "Access from AWS VPC for Personal System"

  # This makes Terraform remove the 0.0.0.0/0 rule if it exists
  lifecycle {
    replace_triggered_by = [
      mongodbatlas_network_peering.peer
    ]
  }
}