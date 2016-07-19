#!/bin/bash
CLUSTERS=$1
SERVICE_NAME=$2
for cluster in $CLUSTERS
do
	TASK_FAMILY=$(aws ecs describe-services --service $SERVICE_NAME --cluster $cluster --output text --query 'services[].taskDefinition' | cut -d '/' -f 2 | cut -d ':' -f 1) 
	TASK_ID=$(aws ecs list-tasks --cluster $cluster --family $TASK_FAMILY | awk '{print $2}' | cut -d '/' -f 2)
	if [ -n "$TASK_ID" ]
	then
		CONTAINER_INSTANCE=$(aws ecs describe-tasks --tasks $TASK_ID --cluster $cluster --output text --query 'tasks[].containerInstanceArn')
		for container in $CONTAINER_INSTANCE
		do
			INSTANCE_ID=$(aws ecs describe-container-instances --container-instances $container --cluster $cluster --output text --query 'containerInstances[0].ec2InstanceId')
			PRIVATE_IP=$(aws ec2 describe-instances  --instance-id $INSTANCE_ID --output text --query 'Reservations[].Instances[].PrivateIpAddress')
			echo $INSTANCE_ID $PRIVATE_IP
		done
	else
		echo "not found"
	fi
done









