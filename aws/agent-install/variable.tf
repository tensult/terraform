variable "profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "url_mcafee_redhat" {
  description = "url_mcafee_redhat"
}

variable "url_snow_redhat" {
  description = "url_snow_redhat"
}

variable "url_mcafee_centos" {
  description = "url_mcafee_centos"
}

variable "url_snow_centos" {
  description = "url_snow_centos"
}

variable "url_mcafee_amzlinux" {
  description = "url_mcafee_amzlinux"
}

variable "url_snow_amzlinux" {
  description = "url_snow_amzlinux"
}

variable "url_mcafee_ubuntu" {
  description = "url_mcafee_ubuntu"
}

variable "url_snow_ubuntu" {
  description = "url_snow_ubuntu"
}

variable "url_snow_agent_windows" {
  description = "url_snow_agent_windows"
}

variable "url_scom_agent_windows" {
  description = "url_scom_agent_windows"
}

variable "scom_management_group" {
  description = "SCOM management group"
}

variable "url_mcafee_windows" {
  description = "url_mcafee_windows"
}

variable "url_sccm_agent_windows" {
  description = "url_SCCM_agent_windows"
}

variable "sccm_server" {
  description = "SCCM Server Details"
}

variable "sitecode" {
  description = "SCCM Server Sitecode "
  default     = "SMT"
}

variable "url_awscli_windows" {
  description = "url_awscli_windows"
}
