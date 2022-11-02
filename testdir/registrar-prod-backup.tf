

#/////***************** AWS Backup **********************\\\\\#


####---------------------------------------------------------------------------------------------------------------###
 # Define local variables

locals {
  

  backups = {
    schedule  = "cron(0 07 ? * * * )" /* UTC Time */
    retention = 30 // days
  }
  backup_environment              = "production"
  backup_vault_name               = "vault-production-registrarcorp"
  backup_plan_name                = "backup-production-ec2-registrarcorp"
  backup_rule_name                = "EC2-30-Days-Retention"
  AWSBackupDefaultServiceRole     = "AWSBackupDefaultServiceRole"
  sns_topic                       = "sns-alerts-production-registrarcorp-backup"
  sns_topic_subscription_endpoint = "registrarcorp@network-redux.incidents.squadcast.com"
  sns_topic_subscription_protocol = "email" 
}

####---------------------------------------------------------------------------------------------------------------###
# Create IAM Role Policy for Backup

data "aws_iam_policy_document" "assume_rolepolicy_backup" {
  
  statement {
      actions = [ "sts:AssumeRole"]
      principals  {
        type =  "Service"
        identifiers = ["backup.amazonaws.com"]
      }
      effect =  "Allow"
    }
}

####---------------------------------------------------------------------------------------------------------------###
# Create IAM Role for Backup

module "prod-iam-role-backup" {
  
  source = "../modules/iam-role"
  role_name = local.AWSBackupDefaultServiceRole
  role_policy = data.aws_iam_policy_document.assume_rolepolicy_backup.json
}

####---------------------------------------------------------------------------------------------------------------###
# Attach AWS Backup Policies to AWSBackupDefaultServiceRole


resource "aws_iam_role_policy_attachment" "role-policy-attachment_backup" {
  depends_on = [module.prod-iam-role-backup]
    
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup", 
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  ])
  role       = local.AWSBackupDefaultServiceRole
  policy_arn = each.value
}


####---------------------------------------------------------------------------------------------------------------###
# Create AWS Backup vault

resource "aws_backup_vault" "registrar-ec2-backup-vault" {
  name = local.backup_vault_name
  tags = {
    name = local.backup_vault_name
  }
}

####---------------------------------------------------------------------------------------------------------------###
# Create AWS Backup Plan

resource "aws_backup_plan" "registrar-ec2-backup-plan" {
  name = local.backup_plan_name

  rule {
    rule_name         = local.backup_rule_name
    target_vault_name = aws_backup_vault.registrar-ec2-backup-vault.name
    schedule          = local.backups.schedule
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = local.backups.retention
      #cold_storage_after = "never" # Need to check
    }
  }
  tags = {
    name = local.backup_rule_name
  }
}

####---------------------------------------------------------------------------------------------------------------###
# Get Role ARN of AWSBackupDefaultServiceRole

data "aws_iam_role" "AWSBackupDefaultServiceRole" {
  depends_on = [module.prod-iam-role-backup]
  name = local.AWSBackupDefaultServiceRole
  
}

####---------------------------------------------------------------------------------------------------------------###
# AWS Backup Selection
resource "aws_backup_selection" "registrar-ec2-backup-selection" {
  iam_role_arn = data.aws_iam_role.AWSBackupDefaultServiceRole.arn
  name         = "TagBasedBackupSelectionEC2"
  plan_id      = aws_backup_plan.registrar-ec2-backup-plan.id 

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "ec2-production"
  }
}

####---------------------------------------------------------------------------------------------------------------###
# Create SNS topic 

resource "aws_sns_topic" "sns_topic" {
  name = local.sns_topic
  
}

/*
resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.sns_policy_document.json
}
*/

####---------------------------------------------------------------------------------------------------------------###
# Create SNS Policy

data "aws_iam_policy_document" "sns_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.sns_topic.arn,
    ]

    sid = "__default_statement_ID"
  }
}

####---------------------------------------------------------------------------------------------------------------###
#Create SNS Policy

resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.sns_policy_document.json
}

####---------------------------------------------------------------------------------------------------------------###
# Create SNS Subscription

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = local.sns_topic_subscription_protocol
  endpoint  = local.sns_topic_subscription_endpoint

}

####---------------------------------------------------------------------------------------------------------------###
# Create Backup Notifications

resource "aws_backup_vault_notifications" "backup_notification" {
  backup_vault_name   = local.backup_vault_name
  sns_topic_arn       = aws_sns_topic.sns_topic.arn
  backup_vault_events = ["BACKUP_JOB_FAILED", "BACKUP_JOB_EXPIRED"]
}


####---------------------------------------------------------------------------------------------------------------###