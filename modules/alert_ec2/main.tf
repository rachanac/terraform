
######### CPU Utilization ##########
 
resource "aws_cloudwatch_metric_alarm" "CPUUtilization" {
  alarm_name                = "cw-${var.client}-${var.envt}-${var.stack}-${var.instance_id}-highCPUutilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
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
    InstanceId = var.instance_id
  }
}

######### Status Check ##########
 

resource "aws_cloudwatch_metric_alarm" "Statuscheckfailed" {
  alarm_name                = "cw-${var.client}-${var.envt}-${var.stack}-${var.instance_id}-Statuscheckfailed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "0.99"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns1]
  ok_actions                = [var.sns1]
  insufficient_data_actions = []
  #treat_missing_data = "notBreaching"
   dimensions = {
    InstanceId = var.instance_id

  }
}

######### Low Disk ##########

resource "aws_cloudwatch_metric_alarm" "ext4-lowdisk" {
  alarm_name                = "cw-${var.client}-${var.envt}-${var.stack}-${var.instance_id}-lowdisk"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
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
     path = "/"
    InstanceId = var.instance_id
    InstanceType = var.instance_type
    ImageId = var.instance_ami
     device = var.instance_device
    fstype = var.instance_fstype
  }
}

######### Memory ##########

resource "aws_cloudwatch_metric_alarm" "highMemoryUtilization" {
  alarm_name                = "cw-${var.client}-${var.envt}-${var.stack}-${var.instance_id}-highMemoryUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns1]
  ok_actions                = [var.sns1]
  insufficient_data_actions = []

   dimensions = {

    InstanceId = var.instance_id
    InstanceType = var.instance_type
    ImageId = var.instance_ami
    
  }
}