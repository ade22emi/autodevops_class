#!/bin/bash

source .env

echo $DOCKERHUB_USERNAME

DockerfileName="/home/adetutu/autodevops_class/Dockerfile"

if [[ -f $DockerfileName ]]
then
    echo "Dockerfile exists already"
    echo "FROM nginx:alpine" > $DockerfileName
else 
    ## file does not exist, create it
    echo "File does not exist..."
    echo "Creating it ..."
    sleep 3
    touch Dockerfile
    echo "$DockerfileName file created ..."
    
    echo "FROM nginx:alpine" >> $DockerfileName    
fi

echo "COPY . /usr/share/nginx/html" >> $DockerfileName
echo "WORKDIR /usr/share/nginx/html" >> $DockerfileName

sudo docker build -t $DOCKERHUB_USERNAME/$APP_NAME:$BUILD_VERSION .


# remove previously running Docker container
echo "Stopping any previuosly running container ... Please wait..."
sleep 2
sudo docker stop $APP_NAME 

echo "Running basic cleanups ..."
sleep 2
sudo docker rm $APP_NAME

echo "Running your container ... ---------------------------"
sudo docker run -d -p $APP_PORT:80 --name $APP_NAME $DOCKERHUB_USERNAME/$APP_NAME:$BUILD_VERSION 
echo "Logging in to Docker Hub..."
sudo docker login -u "$DOCKERHUB_USERNAME" || { echo "Docker login failed!"; exit 1; }

echo "Pushing image to Docker Hub..."
sudo docker push $DOCKERHUB_USERNAME/$APP_NAME:$BUILD_VERSION

if [[ $? -eq 0 ]]; then
    echo "Docker image pushed successfully: $DOCKERHUB_USERNAME/$APP_NAME:$BUILD_VERSION"
else
    echo "Failed to push Docker image!"
    exit 1
fi

echo "Application deployed and pushed to Docker Hub successfully!"