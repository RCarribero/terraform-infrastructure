# --- Código Python de la Función Lambda de Prueba ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content = <<-EOF
import json
import datetime

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "status": "success",
            "message": "Peticion procesada correctamente por el servicio backend.",
            "timestamp": str(datetime.datetime.utcnow())
        })
    }
EOF
    filename = "index.py"
  }
}

# --- Rol IAM de Ejecución para Lambda ---
resource "aws_iam_role" "lambda_exec" {
  name_prefix = "${var.name}-lambda-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Recurso AWS Lambda ---
resource "aws_lambda_function" "this" {
  function_name    = "${var.name}-test-func"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  tags = var.tags
}

# --- URL Pública de la Función Lambda (Function URL con CORS gestionado por AWS) ---
resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["*"]
    max_age           = 86400
  }
}
