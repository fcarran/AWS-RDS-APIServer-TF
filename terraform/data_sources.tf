data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  count  = length(data.aws_subnets.default.ids) # This will return the number of subnets in the VPC
  vpc_id = data.aws_vpc.default.id
  id     = element(tolist(data.aws_subnets.default.ids), count.index) # This will return the subnet ID in a list
}

data "aws_kms_alias" "default" {
  name = "alias/aws/ssm"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}