resource "aws_ecr_repository" "app" {
  name = "timestamp-api"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ec2" {
  name = "timestamp-api-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

//allow ec2 to read from ecr
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


//allow ec2 to read from ssm
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}




resource "aws_iam_instance_profile" "ec2" {
  name = "timestamp-api-ec2-profile"
  role = aws_iam_role.ec2.name
}
