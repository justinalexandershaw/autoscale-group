// The current region to deploy to.
variable "region" {
  type    = string
  default = "us-west-1"
}

# Create a public/private subnet pair in two different AZs.
variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones to create subnets for."
  default     = ["${var.region}a", "${var.region}b"]
  validation {
    condition     = length(var.availability_zones) < 128
    error_message = "Cannot have more than 128 availability_zones."
  }
}

# The current time.
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}