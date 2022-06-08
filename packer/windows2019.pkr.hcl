data "amazon-ami" "windows-2019" {
  filters = {
    name = "Windows_server-2019-English-Full-Base-*"
  }
  most_recent = true
  owners      = ["801119661308"]
  region      = "us-east-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "windows-2019" {
  ami_name       = "windows-2019-aws-{{timestamp}}"
  instance_type  = "t2.micro"
  communicator   = "winrm"
  region         = "us-east-1"
  source_ami     = "${data.amazon-ami.windows-2019.id}"
  user_data_file = "./scripts/SetupWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
}

build {
  sources = ["source.amazon-ebs.windows-2019"]

  post-processor "manifest" {}
}