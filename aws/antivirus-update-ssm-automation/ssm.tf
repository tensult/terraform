resource "aws_ssm_document" "windows_av_update_automation" {
  name          = "Windows_Antivirus_Update_Automation"
  document_type = "Automation"

  content = "${file("windows_av_update_automation_document.json")}"
}

resource "aws_ssm_document" "linux_av_update_automation" {
  name          = "Linux_Antivirus_Update_Automation"
  document_type = "Automation"

  content = "${file("linux_av_update_automation_document.json")}"
}