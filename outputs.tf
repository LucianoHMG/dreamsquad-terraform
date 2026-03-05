output "frontend_url" {
  description = "URL do Frontend Estático (S3)"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "backend_url" {
  description = "URL do Backend via ALB"
  value       = "http://${aws_lb.backend.dns_name}"
}

output "scheduler_bucket" {
  description = "Bucket S3 onde os arquivos da rotina são inseridos"
  value       = aws_s3_bucket.scheduler.id
}
