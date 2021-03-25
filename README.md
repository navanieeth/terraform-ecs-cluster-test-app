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

Brefibe details about each module:
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
1. update the task definition with the latest image
2. Update the service. 
This can be added as last stage in Jenkins pipeline as below,

stage('Deploy in ECS') {
  steps {
    withCredentials([string(credentialsId: 'AWS_EXECUTION_ROL_SECRET', variable: 'AWS_ECS_EXECUTION_ROL'),string(credentialsId: 'AWS_REPOSITORY_URL_SECRET', variable: 'AWS_ECR_URL')]) {
      script {
        updateContainerDefinitionJsonWithImageVersion()
        sh("/usr/local/bin/aws ecs register-task-definition --region ${AWS_ECR_REGION} --family ${AWS_ECS_TASK_DEFINITION} --execution-role-arn ${AWS_ECS_EXECUTION_ROL} --requires-compatibilities ${AWS_ECS_COMPATIBILITY} --network-mode ${AWS_ECS_NETWORK_MODE} --cpu ${AWS_ECS_CPU} --memory ${AWS_ECS_MEMORY} --container-definitions file://${AWS_ECS_TASK_DEFINITION_PATH}")
        def taskRevision = sh(script: "/usr/local/bin/aws ecs describe-task-definition --task-definition ${AWS_ECS_TASK_DEFINITION} | egrep \"revision\" | tr \"/\" \" \" | awk '{print \$2}' | sed 's/\"\$//'", returnStdout: true)
        sh("/usr/local/bin/aws ecs update-service --cluster ${AWS_ECS_CLUSTER} --service ${AWS_ECS_SERVICE} --task-definition ${AWS_ECS_TASK_DEFINITION}:${taskRevision}")
      }
    }
  }
  
  Note : Already we have set the deployment minimum and maxmum health. So no worries about donwtime. 
