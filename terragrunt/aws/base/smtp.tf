# Provides an SES email identity resource
resource "aws_ses_email_identity" "security_tools" {
  email = "info@security.cdssandbox.xyz"
}

resource "aws_iam_user" "security_tools" {
  name = "SecurityToolsNotificationIAMUser"
}

resource "aws_iam_access_key" "security_tools" {
  user = aws_iam_user.security_tools.name
}

# Attaches a Managed IAM Policy to SES Email Identity resource
data "aws_iam_policy_document" "policy_document" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [aws_ses_email_identity.security_tools.arn]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "SecurityToolsNotificationPolicy"
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_user_policy_attachment" "user_policy" {
  user       = aws_iam_user.security_tools.name
  policy_arn = aws_iam_policy.policy.arn
}
