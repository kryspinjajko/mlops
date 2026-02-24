variable "aws_region" {
  description = "AWS region for state bucket and lock table."
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Project name used in resource names."
  type        = string
  default     = "mlops"
}
