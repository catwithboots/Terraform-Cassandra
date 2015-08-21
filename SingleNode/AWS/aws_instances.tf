/* Cassandra instance */
resource "aws_instance" "casdb01" {
  instance_type     = "${var.instance_type.cassandra}"
  ami               = "${var.instance_ami.ubuntu}"
  key_name          = "${var.user_key}"
  subnet_id         = "${aws_subnet.a.id}"
  source_dest_check = false
  security_groups   = ["${aws_security_group.default.id}"]
  tags {
    Name     = "casdb01"
    Role     = "Cassandra first server."
  }
  root_block_device {
  volume_size             = "40"
  delete_on_termination   = true
  }
  connection {
    host= "${self.public_ip}"
    user = "ubuntu"
    key_file = "${var.bootstrap_key}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y ${var.cassandra.jdk}",
      "sudo apt-get update",
      "sudo curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -",
      "sudo sh -c 'echo \"deb http://debian.datastax.com/community/ stable main\" >> /etc/apt/sources.list.d/datastax.list'",
      "sudo apt-get update",
      "sudo apt-get install -y ${var.cassandra.cassandra} ${var.cassandra.cassandratools}",
      "sudo service cassandra stop",
      "sudo sed -i \"s/Test Cluster/${var.cassandra.clustername}/\" ${var.cassandra.configdir}/cassandra.yaml",
      "sudo sed -i \"s@     - /var/lib/cassandra/data@     - ${var.cassandra.datafiledir}@\" ${var.cassandra.configdir}/cassandra.yaml",
      "sudo sed -i \"s@commitlog_directory: /var/lib/cassandra/commitlog@commitlog_directory: ${var.cassandra.commitlogdir}@\" ${var.cassandra.configdir}/cassandra.yaml",
      "sudo sed -i \"s@saved_caches_directory: /var/lib/cassandra/saved_caches@saved_caches_directory: ${var.cassandra.savedcacheddir}@\" ${var.cassandra.configdir}/cassandra.yaml",
      "sudo service cassandra start"
     ]
  }
}
