package test

import (
  "fmt"
  "net"
  "os"
  "strings"
  "testing"
  "time"

  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestTerraformDeployment(t *testing.T) {
  t.Parallel()

  // 🔐 Fetch GitHub token from environment variable
  githubToken := os.Getenv("TF_VAR_github_token")
  if githubToken == "" {
    t.Fatal("TF_VAR_github_token environment variable not set")
  }

  terraformOptions := &terraform.Options{
    TerraformDir: "../terraform",
    Vars: map[string]interface{}{
      "bucket_name":   "devops-project-artifacts-akankshya",
      "github_owner":  "Akankshya02",
      "github_repo":   "devops-project-repo",
      "github_branch": "main",
      "ec2_ami_id":    "ami-0a1235697f4afa8a4",
      "key_pair_name": "akankshya-key",
      "github_token":  githubToken,
    },
    NoColor: true,
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  // ✅ Check EC2 instance name
  instanceName := terraform.Output(t, terraformOptions, "vite_ec2_name")
  assert.True(t, strings.Contains(instanceName, "vite"), "EC2 instance name should contain 'vite'")

  // ✅ Check EC2 public IP format
  ec2PublicIP := terraform.Output(t, terraformOptions, "ec2_public_ip")
  assert.Regexp(t, `\b(?:\d{1,3}\.){3}\d{1,3}\b`, ec2PublicIP, "EC2 public IP should be a valid IPv4 address")

  // ✅ Check SSH port (22) open on EC2 public IP
  sshAddress := fmt.Sprintf("%s:22", ec2PublicIP)
  timeout := 10 * time.Second
  conn, err := net.DialTimeout("tcp", sshAddress, timeout)
  if err != nil {
    t.Fatalf("Failed to connect to EC2 instance over SSH at %s: %v", sshAddress, err)
  }
  defer conn.Close()
  t.Logf("Successfully connected to EC2 over SSH at %s", sshAddress)
}
