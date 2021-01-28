# ----------------------------------------------------------------------------------------------
# VPC ID
# ----------------------------------------------------------------------------------------------
variable "vpc_id" {
  default = "vpc-0f1e12c219f232b46"
}

# ----------------------------------------------------------------------------------------------
# Public Subnet IDs
# ----------------------------------------------------------------------------------------------
variable "public_subnet_ids" {
  default = ["subnet-0681d2c492225dea3", "subnet-02043047a2857a526"]
  type    = list(string)
}

variable "private_subnet_ids" {
  default = ["subnet-0463e28fe18a6f599", "subnet-02f400a0a5738ef8a"]
  type    = list(string)
}

variable "vpc_security_groups" {
  default = ["sg-02c8769865262abbd"]
  type    = list(string)
}
