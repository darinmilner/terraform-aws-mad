variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "subnet-cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "prefix" {
  type    = string
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

variable "interval" {
  default = 50
}

variable "server-port" {
  default = 8000
}

variable "region" {
  default = "us-east-1"
}
