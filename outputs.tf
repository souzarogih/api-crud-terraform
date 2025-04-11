output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.crud_api.id}.execute-api.${var.region}.amazonaws.com/dev/item"
}