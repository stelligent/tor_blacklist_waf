#!/usr/local/bin/bash -ex

region=${AWS_REGION}

bundle install  #--frozen

stack_name=WAF-Tor-Blacklist-Lambda

cfndsl cfn/lambda_cfndsl.rb > output.json

aws cloudformation validate-template --template-body file://output.json \
                                     --region ${region}

./converge_lambda.rb --stack-name ${stack_name}\
                     --path output.json