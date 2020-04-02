# Udagram Image Filtering Microservice

Udagram is a simple cloud application developed alongside the Udacity Cloud Engineering Nanodegree. It allows users to register and log into a web client, post photos to the feed, and process photos using an image filtering microservice. It has 4 microservices:
- backend-feed runs on expressJS
- backend-user runs on expressJS
- frontend is web frontend built with ionic
- reverseproxy acting as LoadBalancer

## Deployment Screenshots
- It can be find in the `deployment_screenshoots` folder at project root directory. It contains:
1. Docker Hub images
2. Create Cluster CI/CD
3. Rolling Update & A/B Release CI/CD
4. Rollback Revision CI/CD
5. `get pod` images
6. Application running images

## Requirement
- AWS Account. https://aws.amazon.com/
- AWS CLI. https://aws.amazon.com/cli/
- AWS EKS eksct. https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
- kubectl. https://storage.googleapis.com/kubernetes-release/release/
- Docker Hub Account https://hub.docker.com/

## Docker Compose
- To deploy locally using container just run docker compose up inside `udacity/c3-deployment/docker foler`

## CI/CD
- Push build to TravisCI to run travis.yml for integration and deployment to AWS EKS. First time of running an AWS EKS Cluster will be created with 3 nodes and t2.medium vms

## Rolling Update
- Each time change is push to repo, CI/CD will deploy new version of deployment and tag it with TRAVISCI BUILD_ID

## A/B Deployment
- The backend-feed service has separate A and B Deployment. Both of them has label `service=backend-feed` that is used as a `selector` by the `backend-feed service` to serve them. Each of them has 2 replicas which will split the traffic by `50-50`

## Rolling Back
- To Rollback just add $ROLLBACK_REVISION as environment variable in Travis.YML, this will rollback the deployments to the specified revision

# Environment Variables
Make sure to add all these required environment variables using your own credentials.
1. AWS_ACCESS_KEY_ID  
2. AWS_BUCKET  
3. AWS_PROFILE  
4. AWS_REGION  
5. AWS_SECRET_ACCESS_KEY  
6. CLUSTER_NAME  
7. CLUSTER_REGION  
8. DOCKER_BACKEND_FEED_IMAGE  
9. DOCKER_BACKEND_USER_IMAGE  
10. DOCKER_FRONTEND_IMAGE  
11. DOCKER_PASSWORD  
12. DOCKER_REVERSEPROXY_IMAGE  
13. DOCKER_USERNAME  
14. JWT_SECRET  
15. K8_BACKEND_FEED_DEPLOYMENT_NAME
16. K8_BACKEND_FEED_VERSION_B_DEPLOYMENT_NAME
16. K8_BACKEND_USER_DEPLOYMENT_NAME  
17. K8_FRONTEND_DEPLOYMENT_NAME  
18. K8_REVERSEPROXY_DEPLOYMENT_NAME  
19. POSTGRESS_DB  
20. POSTGRESS_HOST  
21. POSTGRESS_PASSWORD  
22. POSTGRESS_USERNAME  
23. URL