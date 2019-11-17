variable "profile" {
  description = "AWS Profile"
  default     = "default"
}

variable "role_name" {
  description = "Name of role"
}

variable "permitted_account_id" {
  description = "Account ID of AWS account which gets the permission to the role"
}

variable "role_policy_arn" {
  description = "Policy ARN for assume role"
  default     = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "role_session_duration" {
  description = "Role Session duration"
  default     = 43200
}
