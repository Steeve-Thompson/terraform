resource "aws_lambda_function" "terraform_lambda_function" {
  function_name = "terraform_lambda"
  handler = "lambda_handler"
  role = aws_iam_role.terraform_lambda.arn
  runtime = "python3.6"
  filename = "lambda_func.zip"
}

resource "aws_iam_role" "terraform_lambda" {
  name = "${var.Application_Name}_terraform_role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.Application_Name}_terraform_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:*"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role = aws_iam_role.terraform_lambda.id
}