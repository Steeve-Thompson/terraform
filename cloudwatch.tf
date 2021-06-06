### Cloudwatch Events ###
# Event rule: Runs at 8pm during working days
resource "aws_cloudwatch_event_rule" "start_instances_event_rule" {
  name = "start_instances_event_rule"
  description = "Starts stopped EC2 instances"
  schedule_expression = "cron(0 8 ? * MON-FRI *)"
  depends_on = ["aws_lambda_function.terraform_lambda_function"]
}

# Runs at 8am during working days
resource "aws_cloudwatch_event_rule" "stop_instances_event_rule" {
  name = "stop_instances_event_rule"
  description = "Stops running EC2 instances"
  schedule_expression = "cron(0 20 ? * MON-FRI *)"
  depends_on = ["aws_lambda_function.terraform_lambda_function"]
}

# Event target: Associates a rule with a function to run
resource "aws_cloudwatch_event_target" "start_instances_event_target" {
  target_id = "start_instances_lambda_target"
  rule = aws_cloudwatch_event_rule.start_instances_event_rule.name
  arn = aws_lambda_function.terraform_lambda_function.arn
  input = <<EOF
{
  "action": "start",
  "AutoStartStop": "TRUE"
}
EOF
}

resource "aws_cloudwatch_event_target" "stop_instances_event_target" {
  target_id = "stop_instances_lambda_target"
  rule = aws_cloudwatch_event_rule.stop_instances_event_rule.name
  arn = aws_lambda_function.terraform_lambda_function.arn
  input = <<EOF
{
  "action": "stop",
  "AutoStartStop": "TRUE"
}
EOF
}

# AWS Lambda Permissions: Allow CloudWatch to execute the Lambda Functions
resource "aws_lambda_permission" "allow_cloudwatch_to_call_start_scheduler" {
  statement_id = "StartAllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.start_instances_event_rule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_scheduler" {
  statement_id = "StopAllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.stop_instances_event_rule.arn
}