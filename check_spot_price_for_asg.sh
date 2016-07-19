#!/bin/bash
regions=$(aws ec2 describe-regions --output text --query 'Regions[].RegionName')
CURRENT_DATE=`date +%Y-%m-%dT%H:%M:%S`
HOUR_AGO_DATE=$(date +%Y-%m-%dT%H:%M:%S -d "1hour ago")

for region in $regions
do
	asg=$(aws autoscaling describe-auto-scaling-groups --region $region --output text --query 'AutoScalingGroups[].AutoScalingGroupName')
	for asg_name in $asg
	do
		lc=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg_name --region $region --output text --query 'AutoScalingGroups[].LaunchConfigurationName')
		instance_type=$(aws autoscaling describe-launch-configurations --launch-configuration-names $lc --region $region --output text --query 'LaunchConfigurations[].InstanceType')
		zones=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg_name --region $region --output text --query 'AutoScalingGroups[].AvailabilityZones[]')
		for zone in $zones
        	do
                		spotprice=$(aws ec2 describe-spot-price-history --region $region --instance-types $instance_type --filters Name="product-description",Values="Linux/UNIX" --start-time $HOUR_AGO_DATE --end-time $CURRENT_DATE --query 'SpotPriceHistory[].[AvailabilityZone,SpotPrice]' --output text --availability-zone $zone | tail -n 1 | awk '{print $2}')
				echo $region $asg_name $instance_type $zone $spotprice
		break
		done
	done
done
