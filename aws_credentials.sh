#!/usr/bin/env bash

mkdir -p ~/.aws

#Put AWS Credential in ~/.aws path
cat > ~/.aws/credentials << EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOL

#Put AWS Config in ~/.aws path
cat > ~/.aws/config << EOL
[default]
region = ${CLUSTER_REGION}
EOL
