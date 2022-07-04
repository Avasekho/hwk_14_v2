#!/bin/bash
apt update -y
apt install -y tomcat9 awscli
aws s3 cp s3://boxfuze.avasekho.test/hello-1.0.war /var/lib/tomcat9/webapps/hello-1.0.war