# ECR Repository for MaidCentral App
resource "aws_ecr_repository" "mc_app" {
  name                 = "mc-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "mc-app"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}

# Output the repository URL
output "ecr_repository_url" {
  value       = aws_ecr_repository.mc_app.repository_url
  description = "ECR Repository URL for mc-app"
}