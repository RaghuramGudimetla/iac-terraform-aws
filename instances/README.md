# EC2 Instances

Use instancekey to ssh to the machine
Make sure the inbound is set to public

# SSH into the instance
ssh -i instancekey.pem ec2-user@ec2-XX-XXX-XX-XX.ap-southeast-2.compute.amazonaws.com

# Reference Links:
https://www.cyberciti.biz/faq/how-to-install-docker-on-amazon-linux-2/
https://medium.com/@viveknavadia/how-to-create-docker-images-and-deploy-it-using-ecr-ecs-943e8bfc6c94

pip install urllib3==1.26.6 

# Copying files
scp -i instancekey.pem /c/personal/Repositories/iac-terraform-aws/instances/Dockerfile ec2-user@ec2-XX-XXX-XX-XX.ap-southeast-2.compute.amazonaws.com:/home/ec2-user

# Build the image
docker build -t myubuntu:latest .
docker run -d --name test -p 3000:3000 myubuntu:latest

# ECR steps
1. Create ECR repository
2. Create a user to have permissions on the repo
3. Create acces key secrets for the user
4. Use 'aws configure' on the ec2 instance to get authenticated

# Docker push steps
1. docker tag myubuntu:latest 886192468297.dkr.ecr.ap-southeast-2.amazonaws.com/node_image
2. aws ecr get-login-password | docker login --username AWS --password-stdin 886192468297.dkr.ecr.ap-southeast-2.amazonaws.com
    ---
    WARNING! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
    Configure a credential helper to remove this warning. See
    https://docs.docker.com/engine/reference/commandline/login/#credentials-store

    Login Succeeded
    ---
3. docker push 886192468297.dkr.ecr.ap-southeast-2.amazonaws.com/node_image
4. Copu URL - 886192468297.dkr.ecr.ap-southeast-2.amazonaws.com/node_image:latest