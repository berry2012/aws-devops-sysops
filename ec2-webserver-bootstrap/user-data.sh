#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo yum install -y git
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 
export META_INST_ID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id`
cd /var/www/html
echo "<!DOCTYPE html>" >> index.html
echo "<html lang="en">" >> index.html
echo "<head>" >> index.html
echo "    <title>EC2 Instance</title>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "                <div>Your EC2 Instance is running!</div>" >> index.html
echo "                <div>Instance Id: $META_INST_ID</div>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
sudo service httpd start