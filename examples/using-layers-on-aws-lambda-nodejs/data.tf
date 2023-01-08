###############
# Datasources #
###############

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "null_resource" "npm_install_example_fn_layer_nodejs" {
  # NOTE: If you would like to npm install again, please change it manually to the latest epoch timestamp below.
  triggers = {
    run_if_changed = "1672212694912"
  }
  
  # NOTE: Make sure that node version in your environment is v16.x.x
  provisioner "local-exec" {
    command = <<EOF
cd "${path.module}/files/aws_lambda_layer_version/example-fn-layer/nodejs" && \
  npm install
EOF
  }
}

data "archive_file" "example_fn_layer_zip" {
  depends_on  = [null_resource.npm_install_example_fn_layer_nodejs]
  type        = "zip"
  source_dir  = "${path.module}/files/aws_lambda_layer_version/example-fn-layer"
  output_path = "${path.module}/files/aws_lambda_layer_version/example-fn-layer.zip"
}

data "archive_file" "example_fn_zip" {
  type        = "zip"
  source_file = "${path.module}/files/aws_lambda_function/example-fn/index.js"
  output_path = "${path.module}/files/aws_lambda_function/example-fn.zip"
}
