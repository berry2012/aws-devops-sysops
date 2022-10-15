# Sample Container Node js Application deployment with Elastic Beanstalk


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
docker build -t eb .
docker run -d -p 8080:8080 --name eb eb
docker ps
curl http://localhost:8080
```


# Deploy to Elastic Beanstalk

## Download the source code and then initialize. Follow the command line instructions

```
    cd nodejs-app-docker
    eb init
    
```


## Deployment

```
    eb create

    eb health 
    
    eb open
 ```

## Clean Up

```
eb terminate --all
```