#Creating a target group for network load balancer
resource "aws_alb_target_group" "target_group" {
  depends_on           =  [ "aws_alb.nlb"]
  name                 = "${var.project_name}-${var.env}-${var.component}-tg"
  port                 = "${var.nlb_tg_port}"
  protocol             = "${var.nlb_tg_protocol}"
  vpc_id               = "${var.vpc_id}"
  
  #Create TCP health check
  health_check {
    protocol = "${var.nlb_health_check_protocol}"
  }
  
  tags = {
    Env         = var.env
    Project     = var.project_name
    Name        = "${var.project_name}-${var.env}-${var.component}-tg"
    Type        = "targetgroup"
    Component   = var.component
  }
}

#Creating network load balancer
resource "aws_alb" "nlb" {
  name            = "${var.project_name}-${var.env}-${var.component}-nlb"
  internal        = true
  load_balancer_type = "network"
  subnets         = "${var.ecs_subnet_ids}"

  tags = {
    Env         = var.env
    Project     = var.project_name
    Name        = "${var.project_name}-${var.env}-${var.component}-nlb"
    Type        = "nlb"
    Component   = var.component
  }
}

#Creating network load balancer listener
resource "aws_alb_listener" "tcp" {
  load_balancer_arn = "${aws_alb.nlb.id}"
  port              = "${var.nlb_listener_port}"
  protocol          = "${var.nlb_listener_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.target_group.id}"
    type             = "forward"
  }
}