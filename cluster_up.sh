#!/bin/bash

# Create namespaces
kubectl apply -f definitions/cluster/egov-namespaces.yml

# Create apps in all namespaces
kubectl apply -f definitions/cluster/app/backbone
kubectl apply -f definitions/cluster/app/core
kubectl apply -f definitions/cluster/app/pgr
kubectl apply -f definitions/cluster/app/lams