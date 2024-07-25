locals {
  http-port    = 80
  https-port   = 443
  any-port     = 0
  any-protocol = "-1"
  tcp-protocol = "tcp"
  all-ips      = "0.0.0.0/0"

  common-tags = {
    Env    = "Test"
    Server = "WindowsServer"
  }
}
