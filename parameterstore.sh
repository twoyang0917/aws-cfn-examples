#!/bin/bash

REGION=us-west-2
AWSCLI="aws --region $REGION"

$AWSCLI ssm put-parameter --name /rds/wordpress/dbname \
    --type String --value "wordpress"
    
$AWSCLI ssm put-parameter --name /rds/wordpress/port \
    --type String --value "3306"
    
$AWSCLI ssm put-parameter --name /rds/wordpress/master_username \
    --type String --value "root"

# should not be put it in code, just for demo.
$AWSCLI ssm put-parameter --name /rds/wordpress/master_password \
    --type SecureString --value "wordpress"