provider "aws" {
  region = "us-west-2" # Change to your desired region
}

resource "aws_iam_policy" "my_policy" {
  name        = "lambda-apigateway-policy"
  description = "Allows read-only access to S3 buckets"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1428341300017",
        "Action" : [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow"
      }
    ]
  })
}


# Create IAM role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-apigateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "lambda_exec_policy" {
  name  = "lambda-apigateway-policy"
  roles = [aws_iam_role.lambda_exec_role.name]
  #policy_arn = "arn:aws:iam::aws:policy/lambda-apigateway-policy"
  policy_arn = "arn:aws:iam::905418463549:policy/lambda-apigateway-policy"
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}


# Create Lambda functions for CRUD operations

resource "aws_lambda_function" "create_lambda" {
  function_name = "FunHttps"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"

  # Assuming your Lambda function code is zipped and stored locally
  filename = "function.zip"

  source_code_hash = filebase64sha256("function.zip")
}

resource "aws_lambda_function" "read_lambda" {
  function_name = "read_Https"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"

  # Assuming your Lambda function code is zipped and stored locally
  filename = "function.zip"

  source_code_hash = filebase64sha256("function.zip")
}

resource "aws_lambda_function" "update_lambda" {
  function_name = "update_Https"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"

  # Assuming your Lambda function code is zipped and stored locally
  filename = "function.zip"

  source_code_hash = filebase64sha256("function.zip")
}



resource "aws_lambda_function" "delete_lambda" {
  function_name = "delete_Https"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"

  # Assuming your Lambda function code is zipped and stored locally
  filename = "function.zip"

  source_code_hash = filebase64sha256("function.zip")
}



# Create API Gateway
resource "aws_api_gateway_rest_api" "crud_api" {
  name = "CRUD API"
}

# Define /create resource
resource "aws_api_gateway_resource" "create_resource" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  parent_id   = aws_api_gateway_rest_api.crud_api.root_resource_id
  path_part   = "create"
}

# Define /read resource
resource "aws_api_gateway_resource" "read_resource" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  parent_id   = aws_api_gateway_rest_api.crud_api.root_resource_id
  path_part   = "read"
}

# Define /update resource
resource "aws_api_gateway_resource" "update_resource" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  parent_id   = aws_api_gateway_rest_api.crud_api.root_resource_id
  path_part   = "update"
}

# Define /delete resource
resource "aws_api_gateway_resource" "delete_resource" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  parent_id   = aws_api_gateway_rest_api.crud_api.root_resource_id
  path_part   = "delete"
}

## Create daily quota on API gateway
resource "aws_api_gateway_usage_plan" "daily_quota" {
  name        = "DailyQuotaPlan"
  description = "Daily API request quota"

  quota_settings {
    limit  = 1000
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }
}



# Create method
resource "aws_api_gateway_method" "create_method" {
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  resource_id   = aws_api_gateway_resource.create_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crud_api.id
  resource_id             = aws_api_gateway_resource.create_resource.id
  http_method             = aws_api_gateway_method.create_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.create_lambda.invoke_arn
}


# Read method
resource "aws_api_gateway_method" "read_method" {
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  resource_id   = aws_api_gateway_resource.read_resource.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "read_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crud_api.id
  resource_id             = aws_api_gateway_resource.read_resource.id
  http_method             = aws_api_gateway_method.read_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.read_lambda.invoke_arn
}


# Update method
resource "aws_api_gateway_method" "update_method" {
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  resource_id   = aws_api_gateway_resource.update_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "update_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crud_api.id
  resource_id             = aws_api_gateway_resource.update_resource.id
  http_method             = aws_api_gateway_method.update_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.update_lambda.invoke_arn
}


# Delete method
resource "aws_api_gateway_method" "delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  resource_id   = aws_api_gateway_resource.delete_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crud_api.id
  resource_id             = aws_api_gateway_resource.delete_resource.id
  http_method             = aws_api_gateway_method.delete_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.delete_lambda.invoke_arn
}


# Deploy the API
resource "aws_api_gateway_deployment" "crud_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.create_integration,
    aws_api_gateway_integration.read_integration,
    aws_api_gateway_integration.update_integration,
    aws_api_gateway_integration.delete_integration
  ]
}


# Give API Gateway permission to invoke Lambda functions
resource "aws_lambda_permission" "allow_api_gateway" {
  for_each = {
    "create" : aws_lambda_function.create_lambda.function_name
    "read" : aws_lambda_function.read_lambda.function_name
    "update" : aws_lambda_function.update_lambda.function_name
    "delete" : aws_lambda_function.delete_lambda.function_name
  }

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crud_api.execution_arn}/*/*"
}

resource "aws_dynamodb_table" "users" {
  name           = "lambda-apigateway"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 5

  hash_key = "id"
  attribute {
    name = "id"
    type = "S" # String data type
  }

  tags = {
    Name = "UsersTable"
  }
}


#Create CloudWatch Logs to capture lambda functions and api Gateway access
resource "aws_cloudwatch_log_group" "create_lambda" {
  name = "/aws/lambda/${aws_lambda_function.create_lambda.function_name}"
}

resource "aws_cloudwatch_log_group" "read_lambda" {
  name = "/aws/lambda/${aws_lambda_function.read_lambda.function_name}"
}

resource "aws_cloudwatch_log_group" "update_lambda" {
  name = "/aws/lambda/${aws_lambda_function.update_lambda.function_name}"
}

resource "aws_cloudwatch_log_group" "delete_lambda" {
  name = "/aws/lambda/${aws_lambda_function.delete_lambda.function_name}"
}

