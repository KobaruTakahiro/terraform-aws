## サブネットとか、周辺のものは設定ファイルに含まれていないため、別で設定を行うこと
## やってること
### EC2インスタンスの起動（セキュリティグループの設定は消してる）
### EC2インスタンスにIAMのロールを設定し、S3へのアクセスをできるようにする
### EC2のkey pairの作成
### S3のバケットの作成
##
## 動作確認済みインスタンス
### Ubuntu 16.04 ami-15872773
##
##
##

var "iam" {
    default = "ami-2803ac4e" # Amazon Linux AMI 2017.09.1 (HVM), SSD Volume Type
}
var "instance_type" {
    default = "t2.micro"
}
var "root_volune_size" {
    default = "20"
}
variable "aws_public_key" {}

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
resource "aws_iam_role_policy" "sample-iam-role-policy" {
    name = "instance_role_policy"
    role = "${aws_iam_role.sample-iam-role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "sample-instance-profile" {
    name = "sample_instance_profile"
    role = "${aws_iam_role.sample-iam-role.id}"
}

# S3
resource "aws_s3_bucket" "sample-company" {
    bucket = "sample-company"
    acl = "private"

    tags {
        Name = "sample-company"
    }
}

# EC2 instance
## test instance
resource "aws_instance" "sample-instance" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    subnet_id = "${aws_subnet.public-c.id}" # TODO:  別途設定を行う
    iam_instance_profile = "${aws_iam_instance_profile.sample-instance-profile.name}"
    associate_public_ip_address = false
    depends_on = ["aws_s3_bucket.sample-company"]
    root_block_device = {
        volume_type = "gp2"
        volume_size = "${var.root_volune_size}"
    }
    tags {
        Name = "sample-instance",
        Backup-Generation = "7"
    }
    user_data = "${file("mount_ec2_ubuntu.sh")}"
    key_name = "${aws_key_pair.sample-key.key_name}"
}

# Key pair
resource "aws_key_pair" "sample-key" {
    key_name = "sample-key"
    public_key = "${var.aws_public_key}"
}
