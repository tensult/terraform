resource "aws_ssm_document" "snow_agent_automation" {
  name          = "Snowsoft_Agent_Installation_Automation"
  document_type = "Automation"

  content = "${file("snow_soft_agent_installation_automation.json")}"
}
