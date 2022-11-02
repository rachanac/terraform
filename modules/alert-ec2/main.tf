
 
data "aws_instance" "instance_details" {
  instance_id = var.instance_id
}
 
 ######### CPU Utilization ##########

resource "aws_cloudwatch_metric_alarm" "CPUUtilization" {
  alarm_name                = "cw-${var.prefix}-${var.instance_id}-highCPUutilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns_arn]
  ok_actions                = [var.sns_arn]
  insufficient_data_actions = []
  #treat_missing_data = "notBreaching"
   dimensions = {
    InstanceId = var.instance_id
  }
}

######### Status Check ##########
 

resource "aws_cloudwatch_metric_alarm" "Statuscheckfailed" {
  alarm_name                = "cw-${var.prefix}-${var.instance_id}-Statuscheckfailed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "0.99"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns_arn]
  ok_actions                = [var.sns_arn]
  insufficient_data_actions = []
  #treat_missing_data = "notBreaching"
   dimensions = {
    InstanceId = var.instance_id

  }
}

######### Low Disk ########## 

resource "aws_cloudwatch_metric_alarm" "ext4-lowdisk" {
  count = length(var.instance_devices)
  alarm_name                = "cw-${var.prefix}-${var.instance_id}-lowdisk-${var.instance_devices[count.index].device}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns_arn]
  ok_actions                = [var.sns_arn]
  insufficient_data_actions = []
  #treat_missing_data = "notBreaching"

    dimensions = {
    path          = var.instance_devices[count.index].path
    InstanceId    = var.instance_id
    InstanceType  = data.aws_instance.instance_details.instance_type
    ImageId       = data.aws_instance.instance_details.ami
      device      =  var.instance_devices[count.index].device
    fstype        =  var.instance_devices[count.index].fstype
  }
}

######### Memory ##########

resource "aws_cloudwatch_metric_alarm" "highMemoryUtilization" {
  alarm_name                = "cw-${var.prefix}-${var.instance_id}-highMemoryUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "90"
  alarm_description         = var.region
  actions_enabled           = "true"
  alarm_actions             = [var.sns_arn]
  ok_actions                = [var.sns_arn]
  insufficient_data_actions = []

   dimensions = {
    InstanceId   = var.instance_id
    InstanceType = data.aws_instance.instance_details.instance_type
    ImageId      = data.aws_instance.instance_details.ami
  }
}