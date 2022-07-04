#!/bin/bash
sudo apt update -y
sudo apt install -y git maven default-jdk awscli
HOME=/root/
mkdir -p ~/.ssh/
aws s3 cp s3://avasekho.test.credentials/id_rsa /tmp/id_rsa
aws s3 cp s3://avasekho.test.credentials/config /tmp/config
mv /tmp/id_rsa ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
mv /tmp/config ~/.ssh/config
chmod 600 ~/.ssh/config
git config --global core.sshCommand 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
cd /tmp/
git clone ssh://APKAVNWETNK3NSW6CY4P@git-codecommit.us-east-1.amazonaws.com/v1/repos/boxfuze boxfuze
cd /tmp/boxfuze/
mvn package
aws s3 cp /tmp/boxfuze/target/hello-1.0.war s3://boxfuze.avasekho.test/hello-1.0.war