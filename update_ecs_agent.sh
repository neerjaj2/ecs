#!/bin/bash

### Script to update agent version on the specified cluster

REGION="ap-southeast-1"
CLUSTERS=$(aws ecs list-clusters --output text --region $REGION | awk '{print $2}' | cut -d '/' -f 2)

for cluster in $CLUSTERS
do
	echo $cluster
	CONTAINER_INSTANCES=$(aws ecs list-container-instances --cluster $cluster | awk '{print $2}')
	for container in $CONTAINER_INSTANCES
	do
		CURRENT_VERSION=$(aws ecs describe-container-instances --container-instance $container --cluste $cluster --region $REGION --output text --query 'containerInstances[].versionInfo[].agentVersion')
#		aws ecs update-container-agent --cluster $CLUSTER_NAME --container-instance $container
		echo $container $CURRENT_VERSION 
	done
done
