resource "null_resource" "validate_module_name" {
  count = local.module_name == var.labels["TerraformModuleName"] ? 0 : "Please check that you are using the Terraform module"
}

resource "null_resource" "validate_module_version" {
  count = local.module_version == var.labels["TerraformModuleVersion"] ? 0 : "Please check that you are using the Terraform module"
}