resource "aws_autoscaling_group" "app" {
  name = "timestamp-api-asg"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"  
  }

  health_check_type = "ELB"

  target_group_arns = [
  aws_lb_target_group.app.arn 
]

  tag {
    key                 = "Name"
    value               = "timestamp-api"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "timestamp-api-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}