

provider "aws" {
  region = lookup(var.awsprops, "region")
}

### Master Instance
resource "aws_instance" "Master" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "pub_subnet") #FFXsubnet2
  associate_public_ip_address = "true"
  key_name = lookup(var.awsprops, "keyname")
  vpc_security_group_ids = [lookup(var.awsprops, "sg_name")]
  user_data = <<-EOF
                #!/bin/bash
                 sudo echo "${var.pri_key}" > /home/ec2-user/.ssh/id_rsa
                 sudo chown ec2-user /home/ec2-user/.ssh/id_rsa
                 sudo chmod 600 /home/ec2-user/.ssh/id_rsa
                 sudo apt update -y
                 EOF
  tags = {
    Name ="Master"
    Environment = "Test"
    OS = "Amazon Linux 2"
  }
}

### Worker Instance1
resource "aws_instance" "worker1" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "pub_subnet") #FFXsubnet2
  associate_public_ip_address = "true"
  key_name = lookup(var.awsprops, "keyname")
  vpc_security_group_ids = [lookup(var.awsprops, "sg_name")]
  tags = {
    Name ="Worker1"
    Environment = "Test"
    OS = "Amazon Linux 2"
  }
}

### Worker Instance2
resource "aws_instance" "worker2" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "pub_subnet") #FFXsubnet2
  associate_public_ip_address = "true"
  key_name = lookup(var.awsprops, "keyname")
  vpc_security_group_ids = [lookup(var.awsprops, "sg_name")]
  tags = {
    Name ="Worker2"
    Environment = "Test"
    OS = "Amazon Linux 2"
  }
}

output "Instance_Pub_IPs" {
  value = [aws_instance.Master.*.public_ip, aws_instance.worker1.*.public_ip, aws_instance.worker2.*.public_ip]

}

output "Instance_Pri_IPs" {
  value = [aws_instance.Master.*.private_ip, aws_instance.worker1.*.private_ip, aws_instance.worker2.*.private_ip]
}
