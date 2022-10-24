# Deploy a Web Application to AWS EC2 using AWS CodeDeploy

See up EC2 instances with the user-data `install_codedeploy_agent.sh`

## create the application from cli (optional)
aws deploy create-application --application-name mywebapp

## we need to deploy the entire folder where the application resides
```
cd mywebapp
tree -f .
.
├── ./appspec.yml
├── ./index.html
└── ./scripts
    ├── ./scripts/install_dependencies.sh
    ├── ./scripts/start_server.sh
    └── ./scripts/stop_server.sh
```

## package the deployment application
```
aws deploy push --application-name mywebapp \
    --s3-location s3://<bucket-name>s/codedeploy-mywebapp/app.zip --ignore-hidden-files --region eu-west-1 --profile work
```    