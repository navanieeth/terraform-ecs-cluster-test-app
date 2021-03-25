# Terraform-ECS-Cluster-test-app-ec2
Terraform scripts to create ECS cluster application using EC2

Key Features:
=============
This script can be used to create multiple environments like dev, test, acc and prod with minimal changes. It has been developed in such a way. 

Used S3 as a backend to store the state file. So that it will be maintained in the central repository to make use of other team members. Implemented dynamo db lock to prevent the parallel execution. 

Maintaining two stacks. one to create VPC and subnets. Another one to create a whole ECS cluster till route 53 record attachment. So nothing to worry about the VPC and subnets while destroying and creating the ECS clusters. It will be simple and easy. 

The requirement is to create an application for internal use within the organization. So have created EC2, ALB in private subnets. 

ALB listeners will allow only https requests and it has a redirect rule for HTTP to HTTPS.

Added health check for target group as '/healthcheck'

ALB SG can be whitelisted only with internal organization CIDR range to make it safe.

Implemented auto scaling policy to upscale and downscale the capacity based on CPU and MEM metrics. 

Specified the deployment minimum and maximum percent as 50, 100. So that it will always maintain the 50% of containers during the deployment. 

Brief details about each module:
=================================

1. VPC - It will create the resources like VPC, public and private subnets, NAT, IGW and route configs. 

2. ECS - IAM roles for EC2, SGs and rules,  Launch configuration, Auto Scaling group, Autoscaling policy, ECS cluster, task definition, ecs service, CW log groups and metrics. 

3. ALB - It will create a target group, internal ALB, alb listeners and rules. Attaching r53 record with alb. 

4. dynamo-db - It will create a simple table with a LockID field as the primary key to lock the terraform state during execution.


Deployment process:
===================
Build/Test --> Build Image --> Push to ECR --> Deploy ECS 
To build and push the image to ECR, we can use the jenkins pipeline - https://github.com/navanieeth/docker-build-jenkins-pipeline-maven-test-app

To deploy the app - we have to perform two steps, 
1. update the task definition with the latest image
2. Update the service. 
This can be added as last stage in Jenkins pipeline as,

Refer the ecs-deploy stage - https://github.com/navanieeth/terraform-ecs-cluster-test-app/blob/main/deploy/Jenkinsfile.ecs-deploy

Note : Already we have set the deployment minimum and maximum health. So no worries about downtime. :)
