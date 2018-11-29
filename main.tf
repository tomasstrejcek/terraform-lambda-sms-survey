variable "aws_region" {
  default = "ap-southeast-1"
}

locals {
  twilio_account_sid = "xxx"
  twilio_auth_token = "xxx"
  twilio_phone_number = "xxx"
  email_sender = "xxx"
  access_token = ""
  page_id = ""
  dynamodb_table = "sms_lambda_table"
}

// definitely would need some build pipeline to build it without devdeps
data "archive_file" "lambda-receive" {
  type = "zip"
  source_dir = "lambda-receive-sms/"
  output_path = "lambda-receive-sms.zip"
}

data "archive_file" "lambda-send" {
  type = "zip"
  source_dir = "lambda-send-sms/"
  output_path = "lambda-send-sms.zip"
}

data "archive_file" "lambda-email" {
  type = "zip"
  source_dir = "lambda-send-email/"
  output_path = "lambda-send-email.zip"
}

data "archive_file" "lambda-facebook" {
  type = "zip"
  source_dir = "lambda-publish-facebook/"
  output_path = "lambda-publish-facebook.zip"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_sns_topic" "sns-receive-sms" {
  name = "sns-receive-sms"
}

data "aws_iam_policy_document" "logs-role-put" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}
resource "aws_iam_policy" "logs-role-put" {
  name = "logs-role-put"
  path = "/"
  policy = "${data.aws_iam_policy_document.logs-role-put.json}"
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam-role-policy-sns-publish" {
  name = "iam-role-policy-sns-publish"
  role = "${aws_iam_role.iam_role_for_lambda.id}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.sns-receive-sms.arn}"
    },
    {
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*",
      "Condition":{
        "ForAllValues:StringLike":{
          "ses:Recipients":[
            "*@ghn.cz",
            "*@operam.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "dynamodb:PutItem",
      "Resource": "${aws_dynamodb_table.lambda-db.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "logs-role-put" {
  role = "${aws_iam_role.iam_role_for_lambda.name}"
  policy_arn = "${aws_iam_policy.logs-role-put.arn}"
}

resource "aws_lambda_function" "lambda-receive-sms" {
  filename = "lambda-receive-sms.zip"
  runtime = "nodejs8.10"
  role = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file("lambda-receive-sms.zip"))}"
  function_name = "lambda-receive-sms_handler"
  handler = "index.handler"
  timeout = "10"
  environment = {
    variables {
      SNS_TOPIC = "${aws_sns_topic.sns-receive-sms.arn}"
      REGION = "${var.aws_region}"
      DYNAMO_TABLE = "${local.dynamodb_table}"
    }
  }
}

resource "aws_lambda_function" "lambda-send-sms" {
  filename = "lambda-send-sms.zip"
  runtime = "nodejs8.10"
  role = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file("lambda-send-sms.zip"))}"
  function_name = "lambda-send-sms_handler"
  handler = "index.handler"
  timeout = "10"
  environment = {
    variables {
      REGION = "${var.aws_region}"
      PHONE_NUMBER = "${local.twilio_phone_number}"
      AUTH_TOKEN = "${local.twilio_auth_token}"
      ACCOUNT_SID = "${local.twilio_account_sid}"
      DYNAMO_TABLE = "${local.dynamodb_table}"
    }
  }
}

resource "aws_lambda_function" "lambda-send-email" {
  filename = "lambda-send-email.zip"
  runtime = "nodejs8.10"
  role = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file("lambda-send-email.zip"))}"
  function_name = "lambda-send-email_handler"
  handler = "index.handler"
  timeout = "10"
  environment = {
    variables {
      REGION = "${var.aws_region}"
      EMAIL_SENDER = "${local.email_sender}"
    }
  }
}

resource "aws_lambda_function" "lambda-publish-facebook" {
  filename = "lambda-publish-facebook.zip"
  runtime = "nodejs8.10"
  role = "${aws_iam_role.iam_role_for_lambda.arn}"
  source_code_hash = "${base64sha256(file("lambda-publish-facebook.zip"))}"
  function_name = "lambda-publish-facebook_handler"
  handler = "index.handler"
  timeout = "10"
  environment = {
    variables {
      ACCESS_TOKEN = "${local.access_token}"
      PAGE_ID = "${local.page_id}"
    }
  }
}

resource "aws_api_gateway_rest_api" "sms-api" {
  name = "development-tomas-strejcek"
  # todo: add swagger/open api for input validation
}

resource "aws_api_gateway_resource" "sms-api-res-receive" {
  rest_api_id = "${aws_api_gateway_rest_api.sms-api.id}"
  parent_id = "${aws_api_gateway_rest_api.sms-api.root_resource_id}"
  path_part = "sms-receive"
}

resource "aws_api_gateway_resource" "sms-api-res-send" {
  rest_api_id = "${aws_api_gateway_rest_api.sms-api.id}"
  parent_id = "${aws_api_gateway_rest_api.sms-api.root_resource_id}"
  path_part = "sms-send"
}

module "api-receive" {
  source = "./api"
  rest_api_id = "${aws_api_gateway_rest_api.sms-api.id}"
  resource_id = "${aws_api_gateway_resource.sms-api-res-receive.id}"
  method = "ANY"
  path = "${aws_api_gateway_resource.sms-api-res-receive.path}"
  lambda_arn = "${aws_lambda_function.lambda-receive-sms.arn}"
  lambda_invoke_arn = "${aws_lambda_function.lambda-receive-sms.invoke_arn}"
  gw_execution_arn = "${aws_api_gateway_deployment.sms-api-deployment.execution_arn}"
  region = "${var.aws_region}"
  account_id = "${data.aws_caller_identity.current.account_id}"
}

module "api-send" {
  source = "./api"
  rest_api_id = "${aws_api_gateway_rest_api.sms-api.id}"
  resource_id = "${aws_api_gateway_resource.sms-api-res-send.id}"
  method = "ANY"
  path = "${aws_api_gateway_resource.sms-api-res-send.path}"
  lambda_arn = "${aws_lambda_function.lambda-send-sms.arn}"
  lambda_invoke_arn = "${aws_lambda_function.lambda-send-sms.invoke_arn}"
  gw_execution_arn = "${aws_api_gateway_deployment.sms-api-deployment.execution_arn}"
  region = "${var.aws_region}"
  account_id = "${data.aws_caller_identity.current.account_id}"
}

resource "aws_api_gateway_deployment" "sms-api-deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.sms-api.id}"
  stage_name = "development"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.sms-api-deployment.invoke_url}"
}

resource "aws_sns_topic_subscription" "sns-subscription-lambda-send-email" {
  depends_on = [
    "aws_lambda_function.lambda-send-email",
    "aws_sns_topic.sns-receive-sms"]
  topic_arn = "${aws_sns_topic.sns-receive-sms.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.lambda-send-email.arn}"
}

resource "aws_lambda_permission" "sns-lambda-send-email-allow-sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-send-email.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.sns-receive-sms.arn}"
}

resource "aws_sns_topic_subscription" "sns-subscription-lambda-publish-facebook" {
  depends_on = [
    "aws_lambda_function.lambda-publish-facebook",
    "aws_sns_topic.sns-receive-sms"]
  topic_arn = "${aws_sns_topic.sns-receive-sms.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.lambda-publish-facebook.arn}"
}

resource "aws_lambda_permission" "sns-lambda-publish-facebook-allow-sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-publish-facebook.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.sns-receive-sms.arn}"
}

module "dashboard" {
  source = "./dashboard"
  lambda-receive = "${aws_lambda_function.lambda-receive-sms.function_name}"
  lambda-send = "lambda-send-sms"
  aws_region = "${var.aws_region}"
}

resource "aws_dynamodb_table" "lambda-db" {
  name = "${local.dynamodb_table}"
  read_capacity = 25
  write_capacity = 25
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userNumber"
    type = "S"
  }

  global_secondary_index {
    name               = "userNumberIndex"
    hash_key           = "userNumber"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["id"]
  }

  tags {
    Name = "lambda-table"
    Environment = "production"
  }
}

//module "twilio" {
//  source = "tdooner/twilio/provider"
//  version = "0.0.4"
//}
//
//provider "twilio" {
//  account_sid = "AC834483bb704ac57efd3cc1bc1d169320"
//  auth_token = "9cb8c8fd7e7f759db270cff3dcce9485"
//}
//
//resource "twilio_phonenumber" "virginia" {
//  name = "Virginia"
//
//  location {
//    region = "VA"
//  }
//
//  sms_method = "POST"
//  sms_url = "https://example.com/smsEndpoint"
//}
