region              = "ap-south-1"
bucket_name         = "devops-project-artifacts-akankshya"  # MUST be globally unique

# GitHub config
github_owner        = "Akankshya02"
github_repo         = "devops-project-repo"
github_branch       = "main"

# EC2 config
ec2_ami_id          = "ami-0a1235697f4afa8a4"    # Update with your preferred Linux AMI
key_pair_name       = "ak-key"            # Already created manually

codestar_connection_arn = "arn:aws:codeconnections:ap-south-1:717408097068:connection/da07926e-6553-4757-830c-8f5e8e3ed58d"

codedeploy_app_name = "devops-codedeploy-app"
codedeploy_deployment_group = "devops-deploymenmt-group"

# access_policies = [
#   "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# ]


