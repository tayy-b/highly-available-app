resource "aws_launch_template" "app" {
  name_prefix   = "timestamp-api-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  key_name = var.ec2_key_name

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -eux

    # Install Docker
    dnf update -y
    dnf install -y docker

    # Start Docker
    systemctl enable docker
    systemctl start docker

    # Authenticate with ECR
    aws ecr get-login-password --region ${var.aws_region} | \
      docker login --username AWS --password-stdin \
      ${aws_ecr_repository.app.repository_url}

    # Pull the application image
    docker pull \
      ${aws_ecr_repository.app.repository_url}:${var.app_image_tag}

    # Start the application
    docker run -d \
      --name timestamp-api \
      --restart unless-stopped \
      -p ${var.app_port}:${var.app_port} \
      -e DB_DRIVER=postgres \
      -e LISTEN_ADDR=":${var.app_port}" \
      -e DB_DSN="postgres://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}?sslmode=require" \
      ${aws_ecr_repository.app.repository_url}:${var.app_image_tag}

  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "timestamp-api"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}