#!/usr/bin/env bash

## Check if cluster already exists using EKSCTL
if !( eksctl get cluster --name=$CLUSTER_NAME | grep -q "$CLUSTER_NAME" ); then \
    
    echo "Creating $CLUSTER_NAME cluster with AWS EKS"

    ## Create Cluster with 3 nodes and t2.medium machine
    eksctl create cluster \
        --name "$CLUSTER_NAME" \
        --region "$CLUSTER_REGION" \
        --nodegroup-name standard-workers \
        --node-type t2.medium \
        --nodes 3 \
        --nodes-min 2 \
        --nodes-max 4 \
        --managed

    ## Update Kubectl config file for the cluster
    sudo eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME 

    # Configmap and Secrets Deployment
    sudo kubectl create configmap env-config --from-literal=POSTGRESS_DB=$POSTGRESS_DB --from-literal=POSTGRESS_HOST=$POSTGRESS_HOST --from-literal=AWS_REGION=$AWS_REGION --from-literal=AWS_BUCKET=$AWS_BUCKET --from-literal=AWS_PROFILE=$AWS_PROFILE --from-literal=JWT_SECRET=$JWT_SECRET --from-literal=URL=$URL -o yaml --dry-run | sudo kubectl apply -f -
    sudo kubectl create secret generic env-secret --from-literal=POSTGRESS_USERNAME=$POSTGRESS_USERNAME --from-literal=POSTGRESS_PASSWORD=$POSTGRESS_PASSWORD -o yaml --dry-run | sudo kubectl apply -f -
    sudo kubectl create secret generic aws-secret --from-file=$HOME/.aws/credentials -o yaml --dry-run | sudo kubectl apply -f -
    
    # Apply Deployments
    sudo kubectl apply -f backend-feed-deployment.yaml
    sudo kubectl apply -f backend-feed-version-b-deployment.yaml
    sudo kubectl apply -f backend-user-deployment.yaml
    sudo kubectl apply -f frontend-deployment.yaml
    sudo kubectl apply -f reverseproxy-deployment.yaml

elif [ -n "${ROLLBACK_REVISION}" ]; then 

    echo "Rolling back $CLUSTER_NAME to revision $ROLLBACK_REVISION"

    ## Update Kubectl config file for the cluster
    sudo eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME 

    ## Check if rollback environment variable revision exists in environment var 
    sudo kubectl rollout undo deployment/$K8_BACKEND_FEED_DEPLOYMENT_NAME --to-revision $ROLLBACK_REVISION
    sudo kubectl rollout undo deployment/$K8_BACKEND_FEED_VERSION_B_DEPLOYMENT_NAME --to-revision $ROLLBACK_REVISION
    sudo kubectl rollout undo deployment/$K8_BACKEND_USER_DEPLOYMENT_NAME --to-revision $ROLLBACK_REVISION
    sudo kubectl rollout undo deployment/$K8_FRONTEND_DEPLOYMENT_NAME --to-revision $ROLLBACK_REVISION
    sudo kubectl rollout undo deployment/$K8_REVERSEPROXY_DEPLOYMENT_NAME --to-revision $ROLLBACK_REVISION

else

    echo "$CLUSTER_NAME cluster is already created. Continue to deploy rolling update using TRAVIS_CI build number"

    ## Update Kubectl config file for the cluster
    sudo eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME 

    # Configmap and Secrets Deployment
    sudo kubectl create configmap env-config --from-literal=POSTGRESS_DB=$POSTGRESS_DB --from-literal=POSTGRESS_HOST=$POSTGRESS_HOST --from-literal=AWS_REGION=$AWS_REGION --from-literal=AWS_BUCKET=$AWS_BUCKET --from-literal=AWS_PROFILE=$AWS_PROFILE --from-literal=JWT_SECRET=$JWT_SECRET --from-literal=URL=$URL -o yaml --dry-run | sudo kubectl apply -f -
    sudo kubectl create secret generic env-secret --from-literal=POSTGRESS_USERNAME=$POSTGRESS_USERNAME --from-literal=POSTGRESS_PASSWORD=$POSTGRESS_PASSWORD -o yaml --dry-run | sudo kubectl apply -f -
    sudo kubectl create secret generic aws-secret --from-file=$HOME/.aws/credentials -o yaml --dry-run | sudo kubectl apply -f -
    
    # Rolling Update deployment using the latest docker image tag
    sudo kubectl set image deployment/$K8_BACKEND_FEED_DEPLOYMENT_NAME $K8_BACKEND_FEED_DEPLOYMENT_NAME=$DOCKER_BACKEND_FEED_IMAGE:$TRAVIS_BUILD_ID --record
    sudo kubectl set image deployment/$K8_BACKEND_FEED_VERSION_B_DEPLOYMENT_NAME $K8_BACKEND_FEED_VERSION_B_DEPLOYMENT_NAME=$DOCKER_BACKEND_FEED_IMAGE:$TRAVIS_BUILD_ID --record
    sudo kubectl set image deployment/$K8_BACKEND_USER_DEPLOYMENT_NAME $K8_BACKEND_USER_DEPLOYMENT_NAME=$DOCKER_BACKEND_USER_IMAGE:$TRAVIS_BUILD_ID --record
    sudo kubectl set image deployment/$K8_FRONTEND_DEPLOYMENT_NAME $K8_FRONTEND_DEPLOYMENT_NAME=$DOCKER_FRONTEND_IMAGE:$TRAVIS_BUILD_ID --record
    sudo kubectl set image deployment/$K8_REVERSEPROXY_DEPLOYMENT_NAME $K8_REVERSEPROXY_DEPLOYMENT_NAME=$DOCKER_REVERSEPROXY_IMAGE:$TRAVIS_BUILD_ID --record

    sudo kubectl rollout status deployment.v1.apps/$K8_BACKEND_FEED_DEPLOYMENT_NAME
    sudo kubectl rollout status deployment.v1.apps/$K8_BACKEND_FEED_VERSION_B_DEPLOYMENT_NAME
    sudo kubectl rollout status deployment.v1.apps/$K8_BACKEND_USER_DEPLOYMENT_NAME
    sudo kubectl rollout status deployment.v1.apps/$K8_FRONTEND_DEPLOYMENT_NAME
    sudo kubectl rollout status deployment.v1.apps/$K8_REVERSEPROXY_DEPLOYMENT_NAME

fi
