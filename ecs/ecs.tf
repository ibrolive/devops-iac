#Create cloudwatch log group
resource "aws_cloudwatch_log_group" "loggroup" {
  name = "${var.project_name}-${var.env}-${var.component}-loggroup"

  tags {
    Env         = "${var.env}"
    Project     = "${var.project_name}"
    Name        = "${var.project_name}-${var.env}-${var.component}-loggroup"
    Type        = "loggroup"
    Component   = "${var.component}"
  }
}


#Creating ECS task definition and it's container definition
resource "aws_ecs_task_definition" "task-definition" {
  depends_on           =  ["aws_cloudwatch_log_group.loggroup"]
  family                = "${var.project_name}-${var.env}-${var.component}-ecstaskdef"
  container_definitions = <<DEFINITION
[
  {
    "name": "${var.project_name}-${var.env}-${var.component}-ecscontainer",
	  "cpu": ${var.ecs_container_cpu_units},
    "essential": true,
    "image": "${var.ecs_container_img}",
    "memory": ${var.ecs_container_memory},
    "portMappings": [
      {
        "containerPort": ${var.ecs_container_port},
        "hostPort": 80
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.project_name}-${var.env}-${var.component}-loggroup",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "${var.project_name}-${var.env}-${var.component}-logstream"
        }
    },
    "environment": ${var.environment_variables} 
  }
]
DEFINITION
}

#Creating ECS service
resource "aws_ecs_service" "ecs-service" {
  depends_on           =  ["aws_alb_target_group.target_group"]
  name            = "${var.project_name}-${var.env}-${var.component}-ecsservice"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task-definition.arn}"
  desired_count   = 2
  deployment_minimum_healthy_percent= 0
  launch_type = "${var.ecs_service_launch_type}"
  
  load_balancer {
    target_group_arn = "${aws_alb_target_group.target_group.arn}"
    container_name   = "${var.project_name}-${var.env}-${var.component}-ecscontainer"
    container_port   = "${var.ecs_container_port}"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in  [us-east-1a, us-east-1b]"
  }
}

# Create ECS cluster
resource "aws_ecs_cluster" "ecs-cluster" {
    name = "${var.project_name}-${var.env}-${var.component}-ecscluster"
}