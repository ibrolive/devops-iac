#!/bin/bash
sudo $(aws ecr get-login --no-include-email --region us-east-1 )
sudo docker pull httpd
sudo docker tag httpd:latest "${aws_account_number}.dkr.ecr.us-east-1.amazonaws.com/${ecr_name}:latest"
sudo docker push "${aws_account_number}.dkr.ecr.us-east-1.amazonaws.com/${ecr_name}:latest"
