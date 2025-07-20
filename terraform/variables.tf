# ---- Core AWS Configuration ----
variable "region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1"
}

# ---- S3 Bucket for CodePipeline Artifacts ----
variable "bucket_name" {
  description = "S3 bucket to store CodePipeline artifacts"
  type        = string
}

# ---- GitHub Source Stage ----
variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name for Vite project"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to build"
  type        = string
  default     = "main"
}

# ---- CodeBuild ----
variable "buildspec_path" {
  description = "Path to the buildspec.yml file"
  type        = string
  default     = "buildspec.yml"
}

variable "codebuild_project_name" {
  description = "CodeBuild project name"
  type        = string
  default     = "devops-codebuild-project"
}

# ---- CodePipeline ----
variable "codepipeline_name" {
  description = "CodePipeline name"
  type        = string
  default     = "devops-codepipeline"
}

# ---- EC2 Configuration ----
variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "Type of EC2 instance to create"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

# ---- CodeDeploy ----
variable "deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
  default     = "devops-deployment-group"
}

variable "application_name" {
  description = "Name of the CodeDeploy application"
  type        = string
  default     = "devops-codedeploy-app"
}



