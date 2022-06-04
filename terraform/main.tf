

provider "aws" {
  region = lookup(var.awsprops, "region")
}

### Worker Instance1
resource "aws_instance" "worker1" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "pub_subnet") #FFXsubnet2
  associate_public_ip_address = "true"
  key_name = lookup(var.awsprops, "keyname")
  user_data = <<-EOF
                #!/bin/bash
                 sudo hostnamectl set-hostname Worker1
                 sudo echo "${var.pri_key}" > /home/ec2-user/.ssh/id_rsa
                 sudo chown ec2-user /home/ec2-user/.ssh/id_rsa
                 sudo chmod 600 /home/ec2-user/.ssh/id_rsa
                 sudo yum update -y
                 EOF
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
  user_data = <<-EOF
                #!/bin/bash
                sudo hostnamectl set-hostname Worker2
                 sudo echo "${var.pri_key}" > /home/ec2-user/.ssh/id_rsa
                 sudo chown ec2-user /home/ec2-user/.ssh/id_rsa
                 sudo chmod 600 /home/ec2-user/.ssh/id_rsa
                 sudo yum update -y
                 EOF
  tags = {
    Name ="Worker2"
    Environment = "Test"
    OS = "Amazon Linux 2"
  }
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
                 sudo hostnamectl set-hostname Master
                 sudo echo "${var.pri_key}" > /home/ec2-user/.ssh/id_rsa
                 sudo chown ec2-user /home/ec2-user/.ssh/id_rsa
                 sudo chmod 600 /home/ec2-user/.ssh/id_rsa
                 sudo yum update -y
                 EOF
  tags = {
    Name ="Master"
    Environment = "Test"
    OS = "Amazon Linux 2"
  }
}                 
### Bastion Instance
resource "aws_instance" "Bastion" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "pub_subnet") #FFXsubnet2
  associate_public_ip_address = "true"
  key_name = lookup(var.awsprops, "keyname")
  vpc_security_group_ids = [lookup(var.awsprops, "sg_name")]
  user_data = <<-EOF
                #!/bin/bash
                 sudo hostnamectl set-hostname Bastion
                 sudo echo "${var.pri_key}" > /home/ec2-user/.ssh/id_rsa
                 sudo chown ec2-user /home/ec2-user/.ssh/id_rsa
                 sudo chmod 600 /home/ec2-user/.ssh/id_rsa
                 sudo yum update -y
                 sudo amazon-linux-extras enable ansible2
                 sudo yum install -y ansible
                 echo '[Master]'| sudo tee -a /etc/ansible/hosts
                 echo "${aws_instance.master.private_ip}"| sudo tee -a /etc/ansible/hosts
                 echo '[workers]'| sudo tee -a /etc/ansible/hosts
                 echo "${aws_instance.worker1.private_ip}"| sudo tee -a /etc/ansible/hosts
                 echo "${aws_instance.worker2.private_ip}"| sudo tee -a /etc/ansible/hosts
                 echo "${aws_instance.worker1.private_ip} worker1"| sudo tee -a /etc/hosts
                 echo "${aws_instance.worker2.private_ip} worker2"| sudo tee -a /etc/hosts
                 echo "${aws_instance.master.private_ip} master"| sudo tee -a /etc/hosts                  
                 sudo yum install java-1.8.0 -y
                 sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
                 sudo rpm --import sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
                 sudo yum upgrade
                 sudo yum install jenkins -y
                 sudo systemctl start jenkins
                 cd /
                 git clone https://github.com/saikrissh9/devops.git
                 cd /devops/ansible/
                 ansible-playbook k8s_setup.yml

                 EOF
  tags = {
    Name ="Bastion"
    Environment = "Test"
    OS = "Amazon Linux 2"
  }
}

output "Instance_Pub_IPs" {
  value = [aws_instance.Master.public_ip, aws_instance.worker1.public_ip, aws_instance.worker2.public_ip]

}

output "Instance_Pri_IPs" {
  value = [aws_instance.Master.private_ip, aws_instance.worker1.private_ip, aws_instance.worker2.private_ip]
}

