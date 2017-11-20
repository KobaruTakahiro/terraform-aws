# tresure の部分の名前を変える
#
# 動作確認済み

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

# S3
resource "aws_s3_bucket_object" "treasure" { #TODO: 名前を変える
    bucket = "keio-company"
    acl = "private"
    key    = "treasure/" #TODO: 名前を変える
    source = "/dev/null"
}

# IAM
## user
resource "aws_iam_user" "treasure" { #TODO: 名前を変える
    name = "treasure" #TODO: 名前を変える
    path = "/"
}
## access key
resource "aws_iam_access_key" "treasure-access-key" { #TODO: 名前を変える
    user = "${aws_iam_user.treasure.name}" #TODO: 名前を変える
}

## policy
resource "aws_iam_user_policy" "treasure-policy" { #TODO: 名前を変える
    name = "treasure-policy" #TODO: 名前を変える
    user = "${aws_iam_user.treasure.name}" #TODO: 名前を変える
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Deny",
            "Resource": "arn:aws:s3:::keio-billing*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Action": [
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::keio-company*",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "",
                        "treasure/" #TODO: 名前を変える
                    ]
                }
            }
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::keio-company/treasure", #TODO: 名前を変える
                "arn:aws:s3:::keio-company/treasure/*" #TODO: 名前を変える
            ]
        }
    ]
}
EOF
}
