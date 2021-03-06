# terraform-AWS-docker

A simple PoC using Terraform to build an EC2 instance running Docker with a customized flask application along with redis container for caching. It also includes a load balancer server as we are deploying multiple application containers in a single AWS EC2 instance.

## Features

This terraform script will provision the following :

1. An EC2 Instance with Docker installed in it, along with the below docker containers up and running
    - REDIS container                  : caching
    - IPSTACK(application) containers  : ipstackapp1,ipstackapp2,ipstackapp3 

2. A target group 'ipstack-tg' with 3 registered targets i.e ipstackapp1,ipstackapp2,ipstackapp3 on ports 8081,8082,8083 respectively.

3. An application load balancer which redirects the incoming HTTP traffic to HTTPS based on the Listener rules specified. It also redirects the traffic to the specific target group based on the rules configured in the Listeners.

## Requirements

- An [IP stack Login](https://ipstack.com/) and API for location finding 
- [Terraform v1.0.11](https://www.terraform.io/downloads.html)
- IAM user with administrator access to EC2.
- A valid SSL certificate which has been already imported to ACM.
- [Install docker](https://docs.docker.com/engine/install/)
- [Install docker-compose](https://docs.docker.com/compose/install/)

## Usage

1. Edit the variables.tf file with the desired values.
```
variable "access_key" {
  default = "access-key here" #----------Provide access-key here--------#
}

variable "secret_key" {
  default = "secret-key here"  #----------Provide secretkey here--------#
}

variable "region" {
    default = "ap-south-1" #----------Provide region here--------#
}

variable "ami-id" {
    default = "ami-052cef05d01020f1d" #----------Provide ami-id here--------#
  
}

variable "type" {
    default = "t2.micro" #----------Provide instance-type here--------#
  
}
variable "project" {
    default = "ipstack-app" #----------Provide projectname here--------#
}

variable "vpc-id" {
  default = "vpc-0eb0bd9ac0ac8d067" #----------Provide VPC-id here--------#
}

variable "cert-arn" {
    default = "arn:aws:acm:ap-south-1" #----------Provide SSL cert ARN here--------#
  
}
```
2. Also, please update the setup.sh file with your own API-key from the website [ipstack.com](https://ipstack.com/)
```
#! /bin/bash

sudo yum install -y docker
sudo service docker start
sudo service docker enable

#docker commands to run the container
sudo docker network create api-net

sudo docker container run --name caching --network api-net -d --restart always redis:alpine

sudo docker container run \
-d \
--name ipstackapp1 \
--network api-net \
--restart always \
-p 8081:8080 \
-e CACHING_SERVER=caching \
-e IPSTACK_KEY=e500ddc \ #----------Enter your API-key here---------#
freedafrancis/ipstack-app:latest

sudo docker container run \
-d \
--name ipstackapp2 \
--network api-net \
--restart always \
-p 8082:8080 \
-e CACHING_SERVER=caching \
-e IPSTACK_KEY=e500ddc \ #----------Enter your API-key here---------#
freedafrancis/ipstack-app:latest

sudo docker container run \
-d \
--name ipstackapp3 \
--network api-net \
--restart always \
-p 8083:8080 \
-e CACHING_SERVER=caching \
-e IPSTACK_KEY=e500ddc \ #----------Enter your API-key here---------#
freedafrancis/ipstack-app:latest
```
Once the changes in these files have been made, we can provision the application using the terraform commands given in the next section.

## Provisioning

1. Navigate to the project directory where the required files are already modified and clone the repository.
```
git clone https://github.com/Freeda-F/terraform-aws-docker.git
cd terraform-aws-docker
```
2. Apply 'terraform init' command which is used to initialize a working directory containing Terraform configuration files.
```
$ terraform init
```
3. Then, use 'terraform plan' command to create an execution plan and then use 'terraform apply' to execute the plan. 
```
$ terraform plan
$ terraform apply
```

## Result

Once the build has been completed successfully, you will have a containerized web application which provides geolocation of a given IP address. You can access the web application via a loadbalancer DNS like given below.

Example : http://ipstack-lb-1301061077.ap-south-1.elb.amazonaws.com/123.45.6.7

![image](https://user-images.githubusercontent.com/93197553/147000687-eb672b75-9bf1-457e-bd83-abbde4f91241.png)

![image](https://user-images.githubusercontent.com/93197553/147000754-fe6e0286-4af1-4d03-9e13-e35ff92625de.png)

This application can also work in HTTPS if the load balancer DNS name is given for a valid domain with a valid SSL certificate.
