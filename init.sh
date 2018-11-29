#!/bin/bash

terraform init
cd lambda-receive-sms
nvm use
npm i

touch lambda-receive-sms.zip
touch lambda-send-sms.zip
touch lambda-send-email.zip
touch lambda-publish-facebook.zip

terraform plan -out=xxx.plan

# terraform apply xxx.plan
# rm -f ./lambda-receive-sms.zip
# rm -f ./lambda-send-sms.zip
