variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "subnet-cidr" {
  default = "10.0.1.0/24"
}

variable "prefix" {
  default = "windows-server"
}

variable "instance-type" {
  default = "t2.micro"
}

variable "min-size" {
  default = 1
}

variable "max-size" {
  default = 1
}
