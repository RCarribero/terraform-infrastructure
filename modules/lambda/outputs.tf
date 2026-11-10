output "lambda_arn" {
  description = "ARN de la funcion Lambda"
  value       = aws_lambda_function.this.arn
}

output "lambda_function_name" {
  description = "Nombre de la funcion Lambda"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_url" {
  description = "URL HTTPS directa para invocar la funcion Lambda"
  value       = aws_lambda_function_url.this.function_url
}
