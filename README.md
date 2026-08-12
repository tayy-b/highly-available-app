# Highly available app

## Run Locally

### 1. Start local Postgres

```sh
docker compose up -d db
```

### 2. Run the migration

```sh
psql "postgres://postgres:change-me@localhost:5433/events?sslmode=disable" -f migrations/001_create_events_table.up.sql
```

### 3. Run the API

```sh
go run ./cmd/server
```

### 4. Test the API

```sh
curl -i http://localhost:8080/health
curl -i -X POST http://localhost:8080/events
```

Expected:

- `GET /health` returns `200` with `{"ok": true}`
- `POST /events` returns `201` with `{"status":"created"}`

---

## Run on AWS

### 1. Prerequisites

- AWS account with permissions for VPC, EC2, ALB, ASG, RDS, ECR, and IAM
- AWS CLI, Terraform, Docker, and `psql`

### 2. Configure AWS locally

```sh
aws configure
```

Set:

- AWS Access Key ID
- AWS Secret Access Key
- Default region: `eu-west-2`
- Default output: `json`

### 3. Set Terraform variables

Create `terraform/terraform.tfvars` with:

```tfvars
aws_region    = "eu-west-2"
db_name       = "events"
db_username   = "postgres"
db_password   = ""
app_image_tag = "latest"
ec2_key_name  = "your-keypair-name"
```

### 4. Deploy infrastructure

```sh
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

This creates:

- ECR repository: `timestamp-api`
- ALB and Auto Scaling EC2 instances
- RDS PostgreSQL

### 5. Build and push the Docker image to ECR

Set your AWS account ID:

```sh
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

Log in to ECR:

```sh
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com
```

Build and push:

```sh
docker buildx build --platform linux/amd64 -t ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/timestamp-api:latest --push .
```

### 6. Run the DB migration

RDS is private, so run the migration from an EC2 instance in the VPC through SSH or SSM.

Install `psql` on the EC2 instance:

```sh
sudo dnf install -y postgresql15
```

Connect to RDS:

```sh
psql "postgres://postgres:password@<RDS_ENDPOINT>:5432/events?sslmode=require"
```

Create the table:

```sql
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 7. Test the API with curl

Get the ALB DNS name:

```sh
ALB_DNS=$(aws elbv2 describe-load-balancers --names timestamp-api-alb --query "LoadBalancers[0].DNSName" --output text)
```

Health check:

```sh
curl -i http://${ALB_DNS}/health
```

Create an event:

```sh
curl -i -X POST http://${ALB_DNS}/events
```

Expected:

- `GET /health` returns `200` with `{"ok": true}`
- `POST /events` returns `201` with `{"status":"created"}`




