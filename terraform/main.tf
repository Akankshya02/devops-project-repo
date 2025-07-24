# Get default VPC (for EC2 + security group)
data "aws_vpc" "default" {
  default = true
}

# ------------------------------
# S3 Bucket for CodePipeline Artifacts
# ------------------------------
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "CodePipeline Artifact Bucket"
  }
}

# ------------------------------
# CodePipeline IAM Role & Policies
# ------------------------------
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy" "codepipeline_codebuild_start" {
  name = "AllowCodeBuildStart"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = [
          "arn:aws:codebuild:ap-south-1:717408097068:project/devops-codebuild-project"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_s3_policy" {
  name = "codepipeline-s3-access"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObjectVersion"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}
resource "aws_iam_role_policy" "codestar_access" {
  name = "codepipeline-codestar-access"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = var.codestar_connection_arn
      }
    ]
  })
}
resource "aws_iam_role_policy" "codedeploy_trigger_policy" {
  name = "codedeploy-trigger"
  role = aws_iam_role.codepipeline_role.name  # or any appropriate role

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment"
        ],
        Resource = [
          "arn:aws:codedeploy:ap-south-1:717408097068:deploymentgroup:vite-codedeploy-app/vite-deployment-group"
        ]
      }
    ]
  })
}

# ------------------------------
# CodeBuild IAM Role & Policy
# ------------------------------
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_s3_access" {
  name = "CodeBuildS3Access"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::devops-project-artifacts-akankshya",
          "arn:aws:s3:::devops-project-artifacts-akankshya/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}
resource "aws_iam_role_policy_attachment" "codebuild_logs_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# ------------------------------
# Security Group for EC2
# ------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "devops-ec2-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-ec2-sg"
  }
}

# ------------------------------
# EC2 Instance for Vite App
# ------------------------------
resource "aws_instance" "devops_ec2" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_codedeploy_instance_profile.name


  tags = {
    Name = "devops-ec2-instance"
  }

   user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y ruby wget
              cd /home/ec2-user
              wget https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF
}

# ------------------------------
# CodeBuild Project
# ------------------------------
resource "aws_codebuild_project" "devops_codebuild" {
  name          = var.codebuild_project_name
  description   = "CodeBuild project for Vite app"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENV"
      value = "dev"
    }
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    buildspec = var.buildspec_path
  }

  tags = {
    Environment = "dev"
  }
}

# ------------------------------
# CodePipeline with GitHub v2 via CodeStar Connection
# ------------------------------
resource "aws_codepipeline" "devops_pipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn     = var.codestar_connection_arn
        FullRepositoryId  = "${var.github_owner}/${var.github_repo}"
        BranchName        = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.devops_codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name              = "CodeDeploy"
      category          = "Deploy"
      owner             = "AWS"
      provider          = "CodeDeploy"
      input_artifacts   = ["build_output"]
      version           = "1"
      configuration = {
        ApplicationName     = aws_codedeploy_app.devops_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.devops_group.deployment_group_name
      }
    }
  }
}
resource "aws_codedeploy_app" "devops_app" {
  name = "devops-codedeploy-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "devops_group" {
  app_name              = aws_codedeploy_app.devops_app.name
  deployment_group_name = "devops-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_style {
    deployment_type = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key = "Name"
      type = "KEY_AND_VALUE"
      value = "devops-ec2-instance"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "ec2-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# resource "aws_iam_role_policy_attachment" "ec2_codedeploy_full_access" {
#   role       = aws_iam_role.ec2_codedeploy_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
# }

# Attach AmazonEC2FullAccess to ec2-codedeploy-role
resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Attach AWSCodeDeployFullAccess to ec2-codedeploy-role
resource "aws_iam_role_policy_attachment" "codedeploy_full_access" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}


resource "aws_iam_instance_profile" "ec2_codedeploy_instance_profile" {
  name = "ec2-codedeploy-instance-profile"
  role = aws_iam_role.ec2_codedeploy_role.name
}

resource "aws_iam_policy" "codebuild_dockerhub_secret" {
  name = "AllowSecretsManagerDockerHub"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:ap-south-1:717408097068:secret:dockerhub/credentials-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dockerhub_secret" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_dockerhub_secret.arn
}








    





