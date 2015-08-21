/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.default.id}"
}

/* Public subnet */
resource "aws_subnet" "a" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${var.subnet_availability_zone.a}"
  cidr_block              = "${var.public_subnet_cidr_block.a}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.public"]
  tags {
    Name = "Cassandra a subnet"
  }
}
resource "aws_subnet" "b" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${var.subnet_availability_zone.b}"
  cidr_block              = "${var.public_subnet_cidr_block.b}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.public"]
  tags {
    Name = "Cassandra b subnet"
  }
}

/*
resource "aws_subnet" "c" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${var.subnet_availability_zone.c}"
  cidr_block              = "${var.public_subnet_cidr_block.c}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.public"]
  tags {
    Name = "Cassandra c subnet"
  }
}
*/

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
resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.a.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.b.id}"
  route_table_id = "${aws_route_table.public.id}"
}
/*
resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.c.id}"
  route_table_id = "${aws_route_table.public.id}"
}
*/  