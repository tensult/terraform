resource "aws_ssm_document" "av_update_automation" {
  name          = "Windows_Antivirus_Update_Automation"
  document_type = "Automation"

  content = "${file("windows_av_update_automation_document.json")}"
}

