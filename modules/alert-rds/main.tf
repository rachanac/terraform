############################### RDS CPU ##############################


resource "aws_cloudwatch_metric_alarm" "RDS-CPUUtilization" {
  alarm_name                = "cw-${var.client}-${var.envt}-${var.stack}-${var.db_identifier}-highCPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns1]
  ok_actions                = [var.sns1]
  insufficient_data_actions = []
  #treat_missing_data = "notBreaching"

   dimensions = {

    DBInstanceIdentifier = var.db_identifier

   
  }
}
############################### RDS FreeableMemory ##############################


resource "aws_cloudwatch_metric_alarm" "RDS-FreeableMemory" {
  alarm_name                = "cw-${var.client}-${var.envt}-${var.stack}-${var.db_identifier}-FreeableMemory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "1000000000"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns1]
  ok_actions                = [var.sns1]
  insufficient_data_actions = []
  #treat_missing_data = "notBreaching"

   dimensions = { 
    DBInstanceIdentifier = var.db_identifier
  }
}