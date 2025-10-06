
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/dist/function.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name               = "soa_demo_lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "order" {
  function_name = "soa_demo_order_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = data.archive_file.lambda_zip.output_path
  handler       = "handler.handler"
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout       = 5
  environment { variables = { STAGE = "demo" } }
  tags = local.tags
}

resource "aws_apigatewayv2_api" "http" {
  name          = "soa_demo_http_api"
  protocol_type = "HTTP"
  tags          = local.tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.order.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_order" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /order"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
  tags        = local.tags
}

resource "aws_lambda_permission" "allow_api_gw" {
  statement_id  = "AllowInvokeFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

output "api_base_url" {
  value = "https://${aws_apigatewayv2_api.http.id}.execute-api.${var.aws_region}.amazonaws.com"
}

output "post_order_endpoint" {
  value = "${aws_apigatewayv2_api.http.api_endpoint}/order"
}
