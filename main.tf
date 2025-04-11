provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "bucket_arquivos" {
  bucket = "${var.prefixo}-bucket-arquivos"
}

resource "aws_dynamodb_table" "tabela_crud" {
  name         = "${var.prefixo}-crud-tabela"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefixo}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "crud_lambda" {
  function_name = "${var.prefixo}-lambda-crud"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.9"
  handler       = "handler.lambda_handler"
  filename      = "lambda/lambda_payload.zip"
  
  source_code_hash = filebase64sha256("lambda/lambda_payload.zip")
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.tabela_crud.name
      BUCKET_NAME = aws_s3_bucket.bucket_arquivos.bucket
    }
  }
}

resource "aws_api_gateway_rest_api" "crud_api" {
  name = "${var.prefixo}-crud-api"
}

resource "aws_api_gateway_resource" "crud_resource" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  parent_id   = aws_api_gateway_rest_api.crud_api.root_resource_id
  path_part   = "item"
}

resource "aws_api_gateway_method" "crud_post" {
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  resource_id   = aws_api_gateway_resource.crud_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crud_api.id
  resource_id             = aws_api_gateway_resource.crud_resource.id
  http_method             = aws_api_gateway_method.crud_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.crud_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crud_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "crud_deployment" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
}

resource "aws_api_gateway_stage" "crud_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  deployment_id = aws_api_gateway_deployment.crud_deployment.id
}

