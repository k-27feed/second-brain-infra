# Create a security group for the API
resource "aws_security_group" "api" {
  name        = "secondbrain-${var.environment}-api-sg"
  description = "Security group for API servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "secondbrain-${var.environment}-api-sg"
  }
}

# Create an IAM role for EC2 instances
resource "aws_iam_role" "api" {
  name = "secondbrain-${var.environment}-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "secondbrain-${var.environment}-api-role"
  }
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "api" {
  name = "secondbrain-${var.environment}-api-profile"
  role = aws_iam_role.api.name
}

# Create a policy to allow EC2 to access S3, CloudWatch, etc.
resource "aws_iam_role_policy" "api" {
  name = "secondbrain-${var.environment}-api-policy"
  role = aws_iam_role.api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Create a launch template for the API
resource "aws_launch_template" "api" {
  name_prefix   = "secondbrain-${var.environment}-api-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.api.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.api.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    environment = var.environment
  }))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      delete_on_termination = true
      volume_type           = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "secondbrain-${var.environment}-api"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create an auto scaling group for the API
resource "aws_autoscaling_group" "api" {
  name                = "secondbrain-${var.environment}-api-asg"
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.environment == "production" ? 2 : 1
  min_size            = var.environment == "production" ? 2 : 1
  max_size            = var.environment == "production" ? 4 : 2

  launch_template {
    id      = aws_launch_template.api.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.api.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "secondbrain-${var.environment}-api"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a load balancer for the API
resource "aws_lb" "api" {
  name               = "secondbrain-${var.environment}-api-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.api.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "production"

  tags = {
    Name = "secondbrain-${var.environment}-api-lb"
  }
}

# Create a target group for the API
resource "aws_lb_target_group" "api" {
  name     = "secondbrain-${var.environment}-api-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "secondbrain-${var.environment}-api-tg"
  }
}

# Create a listener for the API
resource "aws_lb_listener" "api_http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# Create an SSL certificate for HTTPS (uncomment for production)
# resource "aws_acm_certificate" "api" {
#   count             = var.environment == "production" ? 1 : 0
#   domain_name       = var.domain_name
#   validation_method = "DNS"
#
#   tags = {
#     Name = "secondbrain-${var.environment}-api-cert"
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Create an HTTPS listener (uncomment for production)
# resource "aws_lb_listener" "api_https" {
#   count             = var.environment == "production" ? 1 : 0
#   load_balancer_arn = aws_lb.api.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.api[0].arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api.arn
#   }
# } 