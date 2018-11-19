resource "aws_ssm_document" "antivirus_update_automation" {
  name          = "Antivirus_Update_Automation"
  document_type = "Automation"

  content = "${file("antivirus_update_automation_document.json")}"
}