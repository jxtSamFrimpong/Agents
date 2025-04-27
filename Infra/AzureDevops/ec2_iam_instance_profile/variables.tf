variable "region" {
  default = "eu-central-1"
}

variable "set_role_path" {
  description = "Set the path for the role"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to give Roles and Policies Created"
  type = object({
    # Name            = string
    ProductCategory = string
    ProductTeam     = string
  })
  default = {
    ProductCategory = "DevOps"
    ProductTeam     = "Cloud"
  }
}

variable "instance_name" {
  description = "Name of the instance profile"
  type        = string
  default = "DefaultEC2SSM"
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  type        = number
  default     = 3600
}

variable "path" {
  description = "Path to the role. See more at https://docs.aws.amazon.com/IAM/latest/UserGuide/Using_Identifiers.html"
  type        = string
  default     = "/exeter/dev/iam/roles/ec2InstanceProfile"
}

variable "additional_policies" {
  description = "Additional Policies to be attached to the instance profile"
  type = list(object({
    name       = string
    path       = optional(string, null)
    actions    = list(string)
    resources  = list(string)
    conditions = optional(any, [])
  }))
  default = [
  ]
}

