package main

exception if {
    some resource in input.resource_changes
    resource.address == "aws_lambda_permission.csp_reports_invoke_function"
}

exception if {
    some resource in input.resource_changes
    resource.address == "aws_lambda_permission.csp_reports_invoke_function_url"
}
