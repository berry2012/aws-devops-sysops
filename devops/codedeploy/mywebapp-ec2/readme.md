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