resource "aws_iam_user" "security_tools" {
  name = "SecurityToolsNotificationIAMUser"
}

resource "aws_iam_access_key" "security_tools" {
  user = aws_iam_user.security_tools.name
}

resource "aws_iam_group_membership" "security_tools_automation" {
  name = "SecurityToolsNotificationIAMGroupMembership"

  users = [
    aws_iam_user.security_tools.name,
  ]

  group = aws_iam_group.security_tools_automation.name
}

resource "aws_iam_group" "security_tools_automation" {
  name = "automation-security-tools-notification-group"
  path = "/automation/securitytools/"
}

resource "aws_iam_group_policy" "security_tools_automation_policy" {
  name   = "automation-security-tools-notification-group-policy"
  group  = aws_iam_group.security_tools_automation.name
  policy = data.aws_iam_policy_document.security_tools_automation.json
}

# Attaches a Managed IAM Policy to SES Email Identity resource
data "aws_iam_policy_document" "security_tools_automation" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["arn:aws:ses:${var.region}:${var.account_id}:identity/${var.domain_name}"]
  }
}
