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

variable "certificate_arn" {
  default = "arn:aws:acm:ap-northeast-1:708988062417:certificate/0016f909-684b-4b4c-bb77-7d0b8201d31a"
}
