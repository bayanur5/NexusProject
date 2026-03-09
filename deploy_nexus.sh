#!/bin/bash
set -e  # exit on any error

# -----------------------------
# Configuration
# -----------------------------
KEY_NAME="my-laptop-key"     # <-- your SSH key name
AWS_REGION="us-east-1"       # Change if needed
MAX_WAIT=600                 # Max wait time for Nexus (seconds)
SLEEP_INTERVAL=10            # Interval between checks

# -----------------------------
# Step 1: Build Nexus AMI with Packer
# -----------------------------
echo "Step 1: Building Nexus AMI with Packer..."
cd ~/NexusProject/step3-packer
packer build nexus.pkr.hcl

# -----------------------------
# Step 2: Get latest Nexus AMI ID
# -----------------------------
echo "Step 2: Getting latest Nexus AMI ID..."
AMI_ID=$(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=nexus-ami-*" \
    --query 'Images | sort_by(@,&CreationDate) | [-1].ImageId' \
    --output text)
echo "Latest AMI ID: $AMI_ID"

# -----------------------------
# Step 3: Deploy EC2 instance with Terraform
# -----------------------------
echo "Step 3: Deploying EC2 instance with Terraform..."
cd ~/NexusProject/step4-terraform

# Clean old provider plugins if needed
rm -rf .terraform/providers
terraform init

terraform apply -auto-approve \
  -var="nexus_ami_id=$AMI_ID" \
  -var="key_name=$KEY_NAME" \
  -var="instance_type=t2.small"

# -----------------------------
# Step 4: Wait for Nexus to be ready
# -----------------------------
PUBLIC_IP=$(terraform output -raw nexus_public_ip)
echo "Waiting for Nexus to be ready at http://$PUBLIC_IP:8081 ..."

ELAPSED=0
until curl -s -o /dev/null http://$PUBLIC_IP:8081 || [ $ELAPSED -ge $MAX_WAIT ]; do
    sleep $SLEEP_INTERVAL
    ELAPSED=$((ELAPSED + SLEEP_INTERVAL))
    echo "Waiting... ($ELAPSED sec)"
done

if curl -s -o /dev/null http://$PUBLIC_IP:8081; then
    echo "-------------------------------------------------"
    echo "✅ Nexus is ready!"
    echo "Access it at: http://$PUBLIC_IP:8081"
    echo "-------------------------------------------------"

    # Optional: open browser automatically (Linux/Mac)
    xdg-open http://$PUBLIC_IP:8081 2>/dev/null || open http://$PUBLIC_IP:8081
else
    echo "⚠️ Nexus did not start within $MAX_WAIT seconds. Check the server logs."
fi 