# EC2 Instance Public IP
output "ec2_public_ip" {
  description = "The public IP address of the deployed EC2 instance"
  value       = aws_instance.vite_ec2.public_ip
}

# S3 Bucket Name
output "codepipeline_artifact_bucket" {
  description = "The S3 bucket used to store CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}

# CodeBuild Project Name
output "codebuild_project_name" {
  description = "Name of the AWS CodeBuild project"
  value       = aws_codebuild_project.vite_codebuild.name
}

# CodePipeline Name
output "codepipeline_name" {
  description = "Name of the AWS CodePipeline"
  value       = var.codepipeline_name
}

# IAM Role ARNs
output "codepipeline_iam_role" {
  description = "IAM role used by CodePipeline"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_iam_role" {
  description = "IAM role used by CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}
