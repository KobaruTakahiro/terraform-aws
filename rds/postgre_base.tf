variable "rds_user_name" {
    default = "root"
}
variable "rds_user_password" {
    default = "root0001"
}
variable "rds_database_name" {
    default = "root"
}
variable "postgres_version" {
    default = "9.6.3"
}
variable "instance_type" {
    default = "db.t2.micro"
}
variable "storege_size" {
    default = 10
}

## private subnet 
resource "aws_subnet" "private-rds-a" {
  vpc_id = "${aws_vpc.xxxx.id}"
  cidr_block = "10.1.2.0/24" # VPCのネットワーク帯に合わせる
  availability_zone = "ap-northeast-1a"
  tags {
    Name = "sample-subnet-private-rds-a"
  }
}
resource "aws_subnet" "private-rds-c" {
  vpc_id = "${aws_vpc.xxxx.id}"
  cidr_block = "10.1.3.0/24" # VPCのネットワーク帯に合わせる
  availability_zone = "ap-northeast-1c"
  tags {
    Name = "sample-subnet-private-rds-c"
  }
}

## security group
### 特定のセキュリティグループからのみアクセスするようにする
resource "aws_security_group" "sample-rds-sg" {
    name = "sample-rds-sg"
    description = "sample rds security group"
    vpc_id = "${aws_vpc.sample.id}"
    ingress {
        from_port = 5432
        to_port = 5432 
        protocol = "tcp"
        security_groups = ["${aws_security_group.xxxx.id}"] # 接続を許可するセキュリティグループ。xxxxを修正
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "sample-rds-sg"
    }
}
# RDS subnet
resource "aws_db_subnet_group" "sample-subnet-group" {
  name = "sample-subnet-group"
  description = "DB Subnet Group"
  subnet_ids = ["${aws_subnet.private-rds-a.id}", "${aws_subnet.private-rds-c.id}"]
}

## instance
resource "aws_db_instance" "sample-rds" {
    allocated_storage = ${var.storege_size}
    storage_type = "gp2"
    engine = "postgres"
    engine_version = "${var.postgres_version}"
    instance_class = "${var.instance_type}"
    username = "${var.rds_user_name}"
    password = "${var.rds_user_password}" # パスワードポリシーに一致するもの
    name = "${var.rds_database_name}"
    vpc_security_group_ids = ["${aws_security_group.sample-rds-sg.id}"]
    backup_retention_period = 7 # バックアップの保存期間
    backup_window = "19:00-19:30" # 午前 4時 - 4時半
    db_subnet_group_name = "${aws_db_subnet_group.sample-subnet-group.name}"
    apply_immediately = "true"
    multi_az = false
    tags {
        Name = "sample-rds"
    }
}
