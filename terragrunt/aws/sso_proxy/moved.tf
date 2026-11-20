moved {
  from = aws_lb.pomerium
  to   = aws_lb.sso_proxy
}

moved {
  from = aws_route53_record.pomerium_subdomains
  to   = aws_route53_record.sso_proxy_subdomains
}

moved {
  from = aws_security_group.pomerium
  to   = aws_security_group.sso_proxy
}

moved {
  from = aws_iam_role.pomerium_container_execution_role
  to   = aws_iam_role.sso_proxy_container_execution_role
}

moved {
  from = aws_iam_role_policy_attachment.pomerium_policies
  to   = aws_iam_role_policy_attachment.sso_proxy_container_policies
}

moved {
  from = aws_iam_policy.pomerium_policies
  to   = aws_iam_policy.sso_proxy_container_policies
}

moved {
  from = aws_iam_role.pomerium_task_execution_role
  to   = aws_iam_role.sso_proxy_task_execution_role
}

moved {
  from = aws_ssm_parameter.pomerium_google_client_id
  to   = aws_ssm_parameter.google_client_id
}

moved {
  from = aws_ssm_parameter.pomerium_google_client_secret
  to   = aws_ssm_parameter.google_client_secret
}
