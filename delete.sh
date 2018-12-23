#!/bin/bash

REGION=us-west-2

# $1 StackName
check_stack()
{
    stacks=$(aws --region $REGION cloudformation describe-stacks --query 'Stacks[].StackName' --output text)
    for i in $stacks; do
        if [ "$1" == "$i" ]; then
            return 0
        fi
    done
    return 1
}

# $1 StackName
delete_stack()
{
    if check_stack $1; then
        echo "[$(date)]: Deleting Stack $1"
        aws --region $REGION cloudformation delete-stack --stack-name $1
        aws --region $REGION cloudformation wait stack-delete-complete --stack-name $1
        echo "[$(date)]: Done"
    fi
}

delete_stack Bastion
delete_stack Wordpress
delete_stack WordpressDB
delete_stack SecurityGroup
delete_stack Network