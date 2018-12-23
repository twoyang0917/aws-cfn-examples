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
# $@ All args for aws cloudformation create-stack
create_stack()
{
    if ! check_stack $1; then
        echo "[$(date)]: Creating Stack $1"
        aws --region $REGION cloudformation create-stack --stack-name $@
        aws --region $REGION cloudformation wait stack-create-complete --stack-name $1
        echo "[$(date)]: Done"
    fi
}

create_stack Network \
    --template-body file://vpc-tmpl.json \
    --parameters \
    ParameterKey=EnvironmentName,ParameterValue="DR"

create_stack SecurityGroup \
    --template-body file://sg-tmpl.json \
    --parameters \
    ParameterKey=VPCStackName,ParameterValue="Network" \
    ParameterKey=OfficeIP,ParameterValue="45.117.99.182/32"

create_stack WordpressDB \
    --template-body file://wordpressdb-tmpl.json \
    --parameters \
    ParameterKey=VPCStackName,ParameterValue="Network" \
    ParameterKey=SGStackName,ParameterValue="SecurityGroup" \
    ParameterKey=DBClass,ParameterValue="db.m1.large" \
    ParameterKey=DBSnapshotIdentifier,ParameterValue="rds-mysql-wordpress"

create_stack Wordpress \
    --template-body file://wordpress-tmpl.json \
    --parameters \
    ParameterKey=VPCStackName,ParameterValue="Network" \
    ParameterKey=SGStackName,ParameterValue="SecurityGroup" \
    ParameterKey=KeyName,ParameterValue="ansible.pub" \
    --capabilities CAPABILITY_NAMED_IAM \
    --disable-rollback

create_stack Bastion \
    --template-body file://bastion-tmpl.json \
    --parameters \
    ParameterKey=VPCStackName,ParameterValue="Network" \
    ParameterKey=SGStackName,ParameterValue="SecurityGroup" \
    ParameterKey=KeyName,ParameterValue="ansible.pub" \
    --capabilities CAPABILITY_NAMED_IAM \
    --disable-rollback
