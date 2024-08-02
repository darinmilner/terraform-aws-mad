# output "lb-listener-arn" {
#   value = aws_lb_listener.http.arn
# }

# output "lb-target-group-name" {
#   value = aws_lb_target_group.lb-tg.name
# }

output "vpc-cidr" {
  value = aws_vpc.main-vpc.cidr_block
}

output "private-subnet-id" {
  value = aws_subnet.private-subnet.id
}

output "public-subnet-id" {
  value = aws_subnet.public-subnet.id
}

output "bucket-name" {
  value = aws_s3_bucket.powershellbucket.bucket
}

output "ec2-public-ip" {
  value = aws_instance.ec2-instance.public_ip
}

output "ec2-private-ip" {
  value = aws_instance.ec2-instance.private_ip
}

output "vpc-id" {
  value = aws_vpc.main-vpc.id
}

# output "eip-endpoint" {
#   value = aws_eip.nat-eip.public_ip
# }
