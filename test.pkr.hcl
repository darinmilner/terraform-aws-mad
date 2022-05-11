variable "aws-region" {
  type    = string
  default = "us-east-1"
}

data "amazon-ami" "amazon-linux-2" {
  filters = {
    name                = "amzn2-ami-hvm-2.*-x86_64-gp2"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws-region
}
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "amazon-linux" {
  ami_name      = "tmp-${local.timestamp}"
  instance_type = "t2.micro"
  # ami_regions = [var.aws-region]
  region                      = var.aws-region
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  source_ami                  = data.amazon-ami.amazon-linux-2.id
  ssh_pty                     = "true"
  ssh_username                = "ec2-user"
  tags = {
    Created-by = "Packer"
    OS_Version = "Amazon Linux"
    Release    = "Latest"
  }
}

build {
  sources = ["source.amazon-ebs.amazon-linux"]

  provisioner "file" {
    destination = "/tmp"
    source      = "/files/"
  }
}