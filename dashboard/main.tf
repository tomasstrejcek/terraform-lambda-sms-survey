locals {
  dashboard-calculator-max-time-color   = "#1f77b4"
  dashboard-calculator-avg-time-color   = "#9467bd"
  dashboard-calculator-memory-color     = "#ff7f0e"
  dashboard-calculator-error-color      = "#d62728"
  dashboard-calculator-invocation-color = "#2ca02c"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "SMSLambdaDashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 7,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda", "Errors",
            "FunctionName", "${var.lambda-receive}",
            "Resource", "${var.lambda-receive}",
            {
              "color": "${local.dashboard-calculator-error-color}",
              "stat": "Sum",
              "period": 10
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.aws_region}",
        "title": "Execution Errors"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 7,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Lambda", "Invocations",
            "FunctionName", "${var.lambda-receive}",
            "Resource", "${var.lambda-receive}",
            {
              "color": "${local.dashboard-calculator-invocation-color}",
              "stat": "Sum",
              "period": 10
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.aws_region}",
        "title": "Invocations"
      }
    }
  ]
}
EOF
}
