#Creating Elastic Container Registry(ECR)
resource "aws_ecr_repository" "ecr" {
  name = "${var.project_name}-${var.env}-${var.component}-ecr"  
}

#Preparing file with shell commands to build docker image and push into ECR repo
data "template_file" "build_docker_img" {
  template = "${file("${path.module}/build_docker_img.sh")}"

  vars {
   ecr_name    = "${aws_ecr_repository.ecr.name}"
   aws_account_number = "${var.aws_account_number}"
  }
}

#Executing shell scripts
resource "null_resource" "execute_build_docker_img_script" {
  provisioner "local-exec" {
   command = "./${data.template_file.build_docker_img.rendered}"   
  }
} 