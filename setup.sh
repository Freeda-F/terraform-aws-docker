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
-e IPSTACK_KEY=eb46997 \
freedafrancis/ipstack-app:latest

sudo docker container run \
-d \
--name ipstackapp2 \
--network api-net \
--restart always \
-p 8082:8080 \
-e CACHING_SERVER=caching \
-e IPSTACK_KEY=eb46997 \
freedafrancis/ipstack-app:latest

sudo docker container run \
-d \
--name ipstackapp3 \
--network api-net \
--restart always \
-p 8083:8080 \
-e CACHING_SERVER=caching \
-e IPSTACK_KEY=eb46997 \
freedafrancis/ipstack-app:latest


