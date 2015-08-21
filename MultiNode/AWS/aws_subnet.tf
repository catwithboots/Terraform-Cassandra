/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.default.id}"
}

/* Public subnet */
resource "aws_subnet" "cassandra" {
  count                   = "${length(split(",",var.availability_zone))}"
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${element(split(",",var.availability_zone),count.index)}"
  cidr_block              = "${element(split(",",var.public_subnet_cidr_block),count.index)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.public"]
  tags {
    Name = "Cassandra ${count.index} subnet"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }
  tags {
    Name = "Cassandra routing table public subnet."
  }
}

resource "aws_main_route_table_association" "public" {
    vpc_id         = "${aws_vpc.default.id}"
    route_table_id = "${aws_route_table.public.id}"
}


/* Associate the routing table to public subnet */
resource "aws_route_table_association" "cassandra" {
  count          = "${length(split(",",var.availability_zone))}"
  subnet_id      = "${element(aws_subnet.cassandra.*.id,count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
 