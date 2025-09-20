
provider "aws" {
  region = "eu-west-1"
}


resource "aws_key_pair" "example" {
  key_name   = "terraform-project1"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "project1-vpc"
  }
}

resource "aws_subnet" "pubsubnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "project1-subnet1"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "project1-igw"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "project1-rt"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.pubsubnet1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "server" {
    count =1
  ami                         = "ami-0bc691261a82b32bc" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.pubsubnet1.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  key_name      = aws_key_pair.example.key_name
  tags = {
    Name = "project1-ec1"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

     # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",
      "sudo apt install -y python3-venv python3-pip",
      "mkdir -p /home/ubuntu/my_flask_app",
      "python3 -m venv /home/ubuntu/my_flask_app/venv",
      "source /home/ubuntu/my_flask_app/venv/bin/activate",
      "pip install flask",
      "sudo python3 app.py &",
    ]
  }
}