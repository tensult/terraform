resource "aws_ssm_document" "AWS_Create_Image" {
  name          = "Create_Golden_Images"
  document_type = "Automation"

  content = "${file("golder_image_creation_automation.json")}"
}


