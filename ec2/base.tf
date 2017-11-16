var "iam" {
    default = "ami-2803ac4e" # Amazon Linux AMI 2017.09.1 (HVM), SSD Volume Type
}
var "instance_type" {
    default = "t2.micro"
}
var "root_volune_size" {
    default = "20"
}

# Subnet
## public
resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.sample.id}"
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "subnet-public-c"
  }
}

# Security Group
# sshのみ許可
resource "aws_security_group" "sample-ec2-sg" {
    name = "sample-ec2-sg"
    description = "sample ec2 security group"
    vpc_id = "${aws_vpc.xxxx.id}" # インスタンスを実行するVPC
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "sample-ec2-sg"
    }
}
## iam instance profile
resource "aws_iam_instance_profile" "sample-instance-profile" {
    name = "sample_instance_profile"
    role = "${aws_iam_role.sample-iam-role.id}"
}
## iam role
resource "aws_iam_role" "sample-iam-role" {
    name = "sample-iam-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": "ec2.amazonaws.com"
            }
        }
    ]
}
EOF
}

# Key pair
resource "aws_key_pair" "sample-key" {
    key_name = "sample-key"
    public_key = "${var.aws_public_key}"
}

# instance
resource "aws_instance" "sample-instance" {
    ami = "${var.iam}" # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
    instance_type = "${var.instance_type}"
    vpc_security_group_ids = [
        "${aws_security_group.sample-ec2-sg.id}"
    ]
    subnet_id = "${aws_subnet.public-c.id}"
    iam_instance_profile = "${aws_iam_instance_profile.sample-instance-profile.name}"
    associate_public_ip_address = false
    root_block_device = {
        volume_type = "gp2"
        volume_size = "${var.root_volune_size}"
    }
    tags {
        Name = "sample-instance"
    }
    user_data = "${file("userdata.sh")}" # userdataのシェル
    key_name = "${aws_key_pair.sample-key.key_name}"
}

# EIP
resource "aws_eip" "sample-eip" {
    instance = "${aws_instance.sample-instance.id}"
    vpc = true
}
