resource "aws_ecrpublic_repository" "generate_sbom_trivy_db" {
  provider        = aws.us-east-1
  repository_name = "${var.product_name}/generate_sbom/trivy-db"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}

resource "aws_ecrpublic_repository" "generate_sbom_trivy_java_db" {
  provider        = aws.us-east-1
  repository_name = "${var.product_name}/generate_sbom/trivy-java-db"

  tags = {
    (var.billing_tag_key) = var.billing_tag_value
    Terraform             = true
    Product               = "${var.product_name}-${var.tool_name}"
  }
}
