# Sample Container Node js Application deployment with Elastic Beanstalk + ECS

- Requires a config file Dockerrun.aws.json at the root of the source code
- Docker images must be prebuilt and stored on a registry e.g. ECR

## Testing the Containerized Nodejs App Locally

### install our dependencies using 

`npm install --save express morgan`

### Confirm everything is running fine

`npm start`

Console log prints: App running at http://localhost:8080
Open a web browser and you should see the text hello world!!
Press Esc to stop the app running.  

### Containerized version

```
docker build -t eb:app1 .
docker run -d -p 8080:8080 --name app1 eb:app1

docker build -t eb:app2 -f Dockerfile2 .
docker run -d -p 8081:8081 --name app2 eb:app2

docker ps
curl http://localhost:8080
curl http://localhost:8081
```

## Storing Docker images
```
aws ecr create-repository --repository-name eb-ecs-repository --region ${REGION}

docker tag eb:app1 ${aws_account_id}.dkr.ecr.${REGION}.amazonaws.com/eb-ecs-repository:app1

docker tag eb:app2 ${aws_account_id}.dkr.ecr.${REGION}.amazonaws.com/eb-ecs-repository:app2

docker login -u AWS -p $(aws ecr get-login-password --region ${REGION}) ${aws_account_id}.dkr.ecr.${REGION}.amazonaws.com

# With IAM profile credential

docker login -u AWS -p $(aws ecr get-login-password --region ${REGION} --profile work) ${aws_account_id}.dkr.ecr.${REGION}.amazonaws.com

docker push ${aws_account_id}.dkr.ecr.${REGION}.amazonaws.com/eb-ecs-repository:app1

docker push ${aws_account_id}.dkr.ecr.${REGION}.amazonaws.com/eb-ecs-repository:app2
```
# Deploy to Elastic Beanstalk + ECS

## Download the source code and then initialize. Follow the command line instructions

```
    cd nodejs-app-docker-ecs
    eb init
    
```


## Deployment

Update the environment variable parameters in the `Dockerrun.aws.json` file

```
    eb create

    eb health 
    
    eb open
 ```

## Clean Up

```
eb terminate --all
```