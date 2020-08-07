#!/bin/bash
/root/.deploy.sh
# Configure sudo for AD users
echo "%dst-ado-posix             ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/01-ado-sudo
restorecon -R -v /etc/sudoers.d/
# Install Docker
yum update -y
#yum install -y docker
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://dl.fedoraproject.org/pub/epel/7/x86_64/
yum-config-manager --enable docker-ce-edge
yum-config-manager --enable docker-ce-test
yum install pigz -y
yum install docker-ce-17.06.1.ce -y
systemctl start docker
yum-config-manager --disable docker-ce-edge
yum-config-manager --disable docker-ce-test
#Install CloudWatch agent
mkdir /etc/awslogs
touch /etc/awslogs/awslogs.conf
#state folder
mkdir /var/lib/awslogs
# Inject the CloudWatch Logs configuration file contents
cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state        
 
[/var/log/messages]
file = /var/log/messages
log_group_name = /var/log/messages
log_stream_name = "${cluster_name}/{container_instance_id}"
datetime_format = %b %d %H:%M:%S

EOF
curl https://s3.amazonaws.com//aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py
./awslogs-agent-setup.py -n -r us-east-1 -c /etc/awslogs/awslogs.conf

# Create directories for ECS agent
mkdir -p /var/log/ecs /var/lib/ecs/data /etc/ecs

# Write ECS config file
cat << EOF > /etc/ecs/ecs.config
ECS_DATADIR=/data
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_LOGFILE=/var/log/ecs-agent-log*.log
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
ECS_LOGLEVEL=info
ECS_CLUSTER=${cluster_name}
EOF

#Install the jq JSON query utility. 
yum install -y jq
#Query the Amazon ECS introspection API to find the container instance ID and set it to an environment variable.
container_instance_id=$(curl -s http://localhost:51678/v1/metadata | jq -r '. | .ContainerInstanceArn' | awk -F/ '{print $2}' )
#Replace the {container_instance_id} placeholders in the file with the value of the environment variable you set in the previous step.
sed -i -e "s/{container_instance_id}/$container_instance_id/g"  /var/awslogs/etc/awslogs.conf

#To re start cloudwatch agent
service awslogs restart

# Write systemd unit file
cat << EOF > /etc/systemd/system/docker-container@ecs-agent.service
[Unit]
Description=Docker Container %I
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker rm -f %i 
ExecStart=/usr/bin/docker run --name %i \
--privileged \
--restart=on-failure:10 \
--volume=/var/run:/var/run \
--volume=/var/log/ecs/:/log:Z \
--volume=/var/lib/ecs/data:/data:Z \
--volume=/etc/ecs:/etc/ecs \
--net=host \
--env-file=/etc/ecs/ecs.config \
amazon/amazon-ecs-agent:latest
ExecStop=/usr/bin/docker stop %i

[Install]
WantedBy=default.target
EOF

systemctl enable docker-container@ecs-agent.service
systemctl start docker-container@ecs-agent.service
