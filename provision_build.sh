#!/bin/bash
sudo apt update -y
sudo apt install -y maven default-jdk awscli
mkdir -p /home/ubuntu/.ssh/
aws s3 cp s3://avasekho.test.credentials/id_rsa /home/ubuntu/id_rsa
aws s3 cp s3://avasekho.test.credentials/config /home/ubuntu/config
mv /home/ubuntu/id_rsa /home/ubuntu/.ssh/id_rsa
chmod 400 /home/ubuntu/.ssh/id_rsa
mv /home/ubuntu/config /home/ubuntu/.ssh/config
chmod 600 /home/ubuntu/.ssh/config
git config --global core.sshCommand 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
git clone ssh://APKAVNWETNK3NSW6CY4P@git-codecommit.us-east-1.amazonaws.com/v1/repos/boxfuze /tmp/boxfuze
cd /tmp/boxfuze/
mvn package
aws s3 cp /tmp/boxfuze/target/hello-1.0.war s3://boxfuze.avasekho.test/hello-1.0.war