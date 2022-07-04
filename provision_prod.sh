#!/bin/bash
su ubuntu
sudo apt update -y
sudo apt install -y tomcat9 awscli
sudo chmod 777 /var/lib/tomcat9/webapps/
aws s3 cp s3://boxfuze.avasekho.test/hello-1.0.war /var/lib/tomcat9/webapps/hello-1.0.war