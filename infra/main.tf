terraform {
  cloud { 
    
    organization = "niket-org" 

    workspaces { 
      name = "niket-website" 
    } 
  } 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = var.aws_region
}

# -----------------------------
# VARIABLES
# -----------------------------
variable "domain_name" {
  description = "Primary domain name for the website"
  default     = "niketrathod.com"
}

variable "aws_region" {
  description = "AWS region for all resources"
  default     = "us-east-1"
}

# -----------------------------
# S3 BUCKET
# -----------------------------
resource "aws_s3_bucket" "niket_rathod_website" {
  bucket = "niket-website-frontend"
}

# -----------------------------
# CLOUDFRONT ORIGIN ACCESS CONTROL
# -----------------------------
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "${var.domain_name}-oac"
  description                       = "OAC for ${var.domain_name} CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------------
# ACM CERTIFICATE (in us-east-1)
# -----------------------------
resource "aws_acm_certificate" "certificate" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = ["www.${var.domain_name}"]
}

# -----------------------------
# CLOUDFRONT DISTRIBUTION
# -----------------------------
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.niket_rathod_website.bucket_regional_domain_name
    origin_id                = "${var.domain_name}-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  # aliases = [var.domain_name, "www.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain_name}-origin"
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress         = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# -----------------------------
# S3 BUCKET POLICY
# -----------------------------
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.niket_rathod_website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.niket_rathod_website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# -----------------------------
# DYNAMODB TABLE
# -----------------------------
resource "aws_dynamodb_table" "visitor_counter" {
  name         = "${var.domain_name}_visitorCounter"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "counterId"

  attribute {
    name = "counterId"
    type = "S"
  }
}

# -----------------------------
# IAM ROLE FOR LAMBDA
# -----------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "updateVisitorCountRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -----------------------------
# LAMBDA FUNCTION
# -----------------------------
resource "aws_lambda_function" "update_counter" {
  filename         = "./lambda/updateVisitorCount.zip"
  function_name    = "updateVisitorCount"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = "./lambda/updateVisitorCount.zip"
}

# -----------------------------
# API GATEWAY
# -----------------------------
resource "aws_apigatewayv2_api" "api" {
  name          = var.domain_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_origins     = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                  = aws_apigatewayv2_api.api.id
  integration_type        = "AWS_PROXY"
  integration_uri         = aws_lambda_function.update_counter.invoke_arn
  description             = "Update visitor counter on ${var.domain_name}"
  payload_format_version  = "2.0"
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
