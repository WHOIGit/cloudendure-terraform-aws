# Get the Route53 zone_id
data "aws_route53_zone" "this" {
  name = "${var.domain_name}." # Notice the dot!!!
  private_zone = false
}

# Create the primary endpoint health check
resource "aws_route53_health_check" "primary" {
  #ip_address        = var.ip_address_primary
  fqdn              = var.health_check_domain_name
  port              = var.health_check_port
  type              = "HTTP"
  resource_path     = var.health_check_resource_path
  failure_threshold = "5"
  request_interval  = "30"
  regions = ["us-east-1", "us-west-1", "us-west-2"]
  disabled = true

  tags = merge(
    var.common_tags,
    {
      CloudEndure_Project = var.domain_name
      Name = "${var.domain_name}-primary-health-check"
    }
  )
}

# Create SNS topic for health check alarm
resource "aws_sns_topic" "this" {
  name      =  "${replace(var.domain_name, ".", "-")}-primary-health-check"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint eandrews@whoi.edu"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = "${replace(var.domain_name, ".", "-")}-primary-health-check-failed"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  unit                = "None"

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }

  alarm_description   = "This metric monitors whether the service endpoint is down or not."
  alarm_actions       = [aws_sns_topic.this.arn]
  #insufficient_data_actions = [aws_sns_topic.this.arn]
  treat_missing_data  = "missing"
  depends_on          = [aws_route53_health_check.primary]
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "${replace(var.domain_name, ".", "-")}-primary-health-check-failed-rule"
  description = "Capture all Route53 Health Check failures"

  event_pattern = <<EOF
{
"source": [
  "aws.cloudwatch"
],
"detail-type": [
  "CloudWatch Alarm State Change"
],
"resources": [
  "${aws_cloudwatch_metric_alarm.this.arn}"
],
"detail": {
  "state": {
    "value": [
      "ALARM"
    ]
  }
}
}
EOF
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "${replace(var.domain_name, ".", "-")}-event-lambda-target"
  arn       = var.lambda_cloudendure_launch_arn
  #arn       = "arn:aws:lambda:${var.aws_region}:${var.aws_account_number}:function:${var.application_name}-${element(var.target-lambda-function, count.index)}"
  input = <<EOF
{
  "source_machine_name": "${var.cloudendure_source_machine_name}"
}
EOF
}

# Add permissions to allow target from Cloudwatch
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id   = "${replace(var.domain_name, ".", "-")}-allow-lambda-execution"
  action         = "lambda:InvokeFunction"
  function_name  = var.lambda_cloudendure_launch_name
  principal      = "events.amazonaws.com"
  source_arn     = aws_cloudwatch_event_rule.this.arn
}

#
# Route 53 Failover setup
#

#
# Create a new elastic ip address to associate with CloudEndure Target machine_type
# Output this value, add it through CE dashboard
# TO DO: Automate with CE API
#
resource "aws_eip" "this" {
  vpc      = true

  tags = merge(
    var.common_tags,
    {
      CloudEndure_Project = var.domain_name
    }
  )
}

#
# primary.DOMAIN primary failover record. Default target for the domain.
#
resource "aws_route53_record" "primary_1" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "primary.${var.domain_name}"
  type    = "A"
  ttl     = 300

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary-primary"
  records         = [var.ip_address_primary]
  health_check_id = aws_route53_health_check.primary.id

}

#
# primary.DOMAIN secondary failover record. Points to secondary.DOMAIN
#
resource "aws_route53_record" "primary_2" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "primary.${var.domain_name}"
  type    = "A"
  #ttl     = 300

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "primary-secondary"
  #records         = ["secondary.${var.domain_name}"]
  alias {
    name                   = aws_route53_record.secondary_1.name
    zone_id                = data.aws_route53_zone.this.zone_id
    evaluate_target_health = false
  }

  depends_on = [
    aws_route53_record.secondary_1,
  ]

}

#
# secondary.DOMAIN primary failover record. Points to the CloudEndure target Elastic IP
#
resource "aws_route53_record" "secondary_1" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "secondary.${var.domain_name}"
  type    = "A"
  ttl     = 300

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "secondary-primary"
  records         = [aws_eip.this.public_ip]
  health_check_id = aws_route53_health_check.primary.id

}
