provider "aws" {
  #   access_key = "${var.aws_access_key}"
  #   secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"

  profile = "${var.aws_profile}"
}



resource "aws_vpc" "sports_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags {
      Name = "sports_vpc"
  }
}

resource "aws_internet_gateway" "sports_gw" {
  vpc_id = "${aws_vpc.sports_vpc.id}"

  tags {
    Name = "sports_gw"
  }
}

## Route Table

resource "aws_route_table" "sports_public_rt" {
  vpc_id = "${aws_vpc.sports_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sports_gw.id}"
  }

  tags {
    Name = "sports_public_rt"
  }
}

resource "aws_default_route_table" "sports_default_rt" {
  default_route_table_id = "${aws_vpc.sports_vpc.default_route_table_id}"

  tags {
    Name = "sports_default_rt"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "sports_public_sb" {
  vpc_id                  = "${aws_vpc.sports_vpc.id}"
  cidr_block              = "${var.cidrs["public"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "sports_public_sb"
  }
}


resource "aws_subnet" "sports_private_sb" {
 vpc_id                  = "${aws_vpc.sports_vpc.id}"
  cidr_block              = "${var.cidrs["private"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "sports_private_sb"
  }
}

resource "aws_lambda_function" "sports_lambda" {
  function_name = "Sports Lambda"
  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "devops-bucket-stuxnet"
  s3_key    = "main.zip"

  handler = "main.handler"
  runtime = "nodejs6.10"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "sports_lambda_policy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "sports_api_gateway" {
  name        = "Sports API Gateway"
  description = "Sports API Gateway Desc"

}

resource "aws_api_gateway_resource" "proxy_res" {
  rest_api_id = "${aws_api_gateway_rest_api.sports_api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.sports_api_gateway.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_meth" {
  rest_api_id   = "${aws_api_gateway_rest_api.sports_api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_res.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sports_ag_lambda_int" {
  rest_api_id = "${aws_api_gateway_rest_api.sports_api_gateway.id}"
  resource_id = "${aws_api_gateway_method.proxy_meth.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_meth.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.sports_lambda.invoke_arn}"
}

resource "aws_api_gateway_method" "sports_proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.sports_api_gateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.sports_api_gateway.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.sports_proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.sports_proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.sports_lambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "sports_ag" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "test"
}


resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sports_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.sports_ag.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "sports_lg" {
  name = "Sports Log Group"

  tags = {
    Environment = "developement"
    Application = "sports"
  }
}
