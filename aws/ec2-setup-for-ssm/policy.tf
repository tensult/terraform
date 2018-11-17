
resource "aws_iam_policy" "ssm_params" {
  name = "EC2-Managed-Instance-SSM-Params"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "kms:Decrypt"
           ],
           "Resource": "${aws_kms_key.ssm.arn}"
       },
       {
           "Effect": "Allow",
           "Action": [
               "ssm:GetParameter"
           ],
           "Resource": "arn:aws:ssm:*:*:parameter/domain/*"
       }
   ]
}
EOF
}

resource "aws_iam_policy" "private_static_s3" {
  name = "PrivateStatic-S3-Limited-Access"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "VisualEditor0",
           "Effect": "Allow",
           "Action": [
               "s3:GetObject",
               "s3:ListBucket"
           ],
           "Resource": [
               "arn:aws:s3:::arn:aws:s3:::${var.s3_bucket}*"
           ]
       },
       {
           "Sid": "VisualEditor1",
           "Effect": "Allow",
           "Action": "s3:ListAllMyBuckets",
           "Resource": "*"
       }
   ]
}
EOF
}