
#Creating launch configuration for auto scaling group 
resource "aws_launch_configuration" "launch-cfg" {
  name_prefix          = "${var.project_name}-${var.env}-${var.component}-launchconfig-"
  image_id             = "${var.gold_ami}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${var.ecs_launch_config_sg}"]
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${var.ecs_instance_profile_id}"

  # aws_launch_configuration can not be modified.
  # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created 
  # before the old one get's destroyed. That's why we use name_prefix instead of name.
  lifecycle {
    create_before_destroy = true
  }
}
# Instances are scaled across availability zones  
resource "aws_autoscaling_group" "asg" {
  name                 = "${var.project_name}-${var.env}-${var.component}-asg"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.launch-cfg.id}"
  vpc_zone_identifier  = ["${var.ecs_subnet_ids}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.project_name}-${var.env}-${var.component}-asg"
      propagate_at_launch = "true"
    },
    {
      key                 = "Project"
      value               = "${var.project_name}"
      propagate_at_launch = "true"
    },
    {
      key                 = "Env"
      value               = "${var.env}"
      propagate_at_launch = "true"
    },
    {
      key                 = "Type"
      value               = "asg"
      propagate_at_launch = "true"
    },
    {
      key                 = "Component"
      value               = "${var.component}"
      propagate_at_launch = "true"
    }
  ]

  lifecycle {
    create_before_destroy = true
  }
}

#User data script to run on container instance
data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
   cluster_name      = "${var.project_name}-${var.env}-${var.component}-ecscluster"
  }
}
