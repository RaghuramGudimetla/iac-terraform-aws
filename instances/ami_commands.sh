# Check and install docker
sudo yum update
sudo yum info docker
sudo yum install docker

# Run commands without super user
sudo usermod -a -G docker ec2-user
id ec2-user
newgrp docker

# Install docker compose
sudo yum install python3-pip
sudo pip3 install docker-compose

# Enable and start docker at boot time
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Find status
# sudo systemctl status docker.service

# Verify the docker
docker version
docker-compose version
# If docker compose needs urllib3 -- pip install urllib3==1.26.6
