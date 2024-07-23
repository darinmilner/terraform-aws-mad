# output "lb-listener-arn" {
#   value = aws_lb_listener.http.arn
# }

# output "lb-target-group-name" {
#   value = aws_lb_target_group.lb-tg.name
# }

output "subnet-ids" {
  value = aws_subnet.public-subnet[*].id 
}

output "bucket-name" {
  value = aws_s3_bucket.powershellbucket.bucket
}