resource "aws_dynamodb_table" "orders" {
  name         = "soa_demo_orders"
  billing_mode = "PAY_PER_REQUEST" # дешево, без лимитов
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }

  tags = local.tags
}

output "orders_table_name" {
  value = aws_dynamodb_table.orders.name
}
