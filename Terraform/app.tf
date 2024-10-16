# IAM

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${local.prefix}-lambda-policy"
  description = "Policy for Lambda function to access required resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # 他に必要な権限を追加することができます
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Lambdaレイヤーのアップロード
resource "aws_lambda_layer_version" "psycopg2_layer" {
  layer_name          = "psycopg2_layer"
  filename            = "../src/layer/psycopg2_layer.zip"
  compatible_runtimes = ["python3.10"] # 使用するランタイム
}

# Resource
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../src/lambda"
  output_path = "api.zip"
}

resource "aws_lambda_function" "api" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.prefix}-api"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60

  vpc_config {
    subnet_ids         = [aws_subnet.my_subnet1.id]
    security_group_ids = [aws_security_group.rds_sg.id]
  }

  layers = [aws_lambda_layer_version.psycopg2_layer.arn]

  environment {
    variables = {
      DB_HOST_PORT = try(aws_db_instance.postgres.endpoint, null),
      DB_NAME      = "postgres"
      DB_USER      = var.db_username
      DB_PASSWORD  = var.db_password
    }
  }
}