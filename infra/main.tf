terraform {
  cloud { 
    
    organization = "niket-org" 

    workspaces { 
      name = "niket-website" 
    } 
  } 

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.11.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# S3 Bucket

resource "aws_s3_bucket" "niketrathod" {
    bucket = "niketrathod.com"
}

# S3 Bucket Policy (lets cloudfront access)

resource "aws_s3_bucket_policy" "niketrathod_policy" {
    bucket = aws_s3_bucket.niketrathod.id
    policy = jsonencode(
        {
            Id        = "PolicyForCloudFrontPrivateContent"
            Statement = [
                {
                    Action    = "s3:GetObject"
                    Condition = {
                        StringEquals = {
                            "AWS:SourceArn" = "arn:aws:cloudfront::681121191318:distribution/E34XNASCEYM453"     
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        Service = "cloudfront.amazonaws.com"
                    }
                    Resource  = "arn:aws:s3:::niketrathod.com/*"
                    Sid       = "AllowCloudFrontServicePrincipal"
                },
            ]
            Version   = "2008-10-17"
        }
    )
}

# Cloudfront Distribution)

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.niketrathod.bucket_regional_domain_name
    origin_access_control_id = "E2MQKBXZ98J5FB"
    origin_id                = "niketrathod.com.s3.us-east-1.amazonaws.com-mdwq2gpnrix"
  }

  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled = true
  price_class = "PriceClass_100"

  aliases = ["niketrathod.com", "www.niketrathod.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "niketrathod.com.s3.us-east-1.amazonaws.com-mdwq2gpnrix"
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
  acm_certificate_arn      = "arn:aws:acm:us-east-1:681121191318:certificate/35225c25-e8f9-49e8-bd53-128ddd642fe1"
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
  cloudfront_default_certificate = false
  }

}

# dynamoDB table

resource "aws_dynamodb_table" "visitor_Counter" {
  name           = "niketrathod.com_visitorCounter"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "counterId"

  attribute {
    name = "counterId"
    type = "S"
  }
}

# allow lambda to assume roles

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
    name = "updateVisitorCountRole"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach DynamoDBFullAccess policy
resource "aws_iam_role_policy_attachment" "DynamoDB_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::681121191318:policy/service-role/AWSLambdaBasicExecutionRole-fc45e792-37dc-4b2a-833d-18063c0a4dc2"
}

# Attach microservice execution policy
resource "aws_iam_role_policy_attachment" "micro_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::681121191318:policy/service-role/AWSLambdaMicroserviceExecutionRole-2e0ad9eb-6462-4935-9c50-5dcc03b3d85d"
}

resource "aws_lambda_function" "my_lambda" {
  filename = "./lambda/updateVisitorCount.zip"
  function_name = "updateVisitorCount"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.13" 
  role = aws_iam_role.lambda_role.arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "niketrathod.com"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_origins = ["*"]
  }

}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"
  description               = "update visitor counter on niketrathod.com"
  payload_format_version = "2.0"
  integration_uri           = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}