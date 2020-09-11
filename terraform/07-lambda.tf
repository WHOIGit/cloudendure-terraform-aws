# Create IAM Role and Policy for Lambda Function

resource "aws_iam_role" "lambda_launch_target_role" {
  name = "lambda-cloudendure-launch-target-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_launch_target_policy" {
  name = "lambda-cloudendure-launch-target-policy"
  role = aws_iam_role.lambda_launch_target_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

# Create ZIP Archive for Function Source Code

data "archive_file" "lambda_launch_zip_dir" {
  type        = "zip"
  source_dir  = "${path.module}/aws-lambdas/cloudendure-launch-target-machine"
  output_path = "${path.module}/aws-lambdas/deployment-pkgs/cloudendure-launch-target-machine.zip"
}

# Create Lambda Function

resource "aws_lambda_function" "lambda_cloudendure_launch" {
  filename         = data.archive_file.lambda_launch_zip_dir.output_path
  source_code_hash = data.archive_file.lambda_launch_zip_dir.output_base64sha256
  function_name    = "cloudendure_launch_target_machine"
  timeout		   = 10
  role             = aws_iam_role.lambda_launch_target_role.arn
  handler          = "cloudendure_launch_target_machine.lambda_handler"
  runtime          = "python3.7"

  environment {
    variables = {
      USER_API_TOKEN = var.cloudendure_user_api_token
    }
  }
}
