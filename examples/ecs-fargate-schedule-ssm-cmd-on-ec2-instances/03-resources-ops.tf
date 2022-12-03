#################
# SSM Documents #
#################

resource "aws_ssm_document" "create_mock_file" {
  name          = "create-mock-file"
  document_type = "Command"
  
  # NOTE: If you update the content and apply that change, 
  #       the default_version of the document will be updated 
  #.      to the latest version automatically.
  content = file("${path.module}/files/aws_ssm_document/create-mock-file.json")
}
