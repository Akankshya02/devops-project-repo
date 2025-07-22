# Output the EC2 instance name
output "vite_ec2_name" {
  description = "The name of the Vite EC2 instance"
  value       = aws_instance.vite_ec2.tags["Name"]
}

# Output the public IP of the EC2 instance
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.vite_ec2.public_ip
}

# Output CodePipeline project name
output "codepipeline_name" {
  description = "The name of the AWS CodePipeline"
  value       = aws_codepipeline.vite_pipeline.name
}

# Output CodeBuild project name
output "codebuild_project_name" {
  description = "The name of the CodeBuild project"
  value       = aws_codebuild_project.vite_codebuild.name
}

# Output the CodeBuild IAM role ARN
output "codebuild_iam_role" {
  description = "IAM Role ARN used by CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}

# Output the CodePipeline IAM role ARN
output "codepipeline_iam_role" {
  description = "IAM Role ARN used by CodePipeline"
  value       = aws_iam_role.codepipeline_role.arn
}

# Output the S3 bucket name used for CodePipeline artifacts
output "codepipeline_artifact_bucket" {
  description = "S3 Bucket name for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}
