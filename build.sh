#!/bin/bash -exl

rvm use jruby-9.0.4.0@lambda_dev --create

gem install bundler -v 1.10.6 --conservative

bundle install

rspec

mvn install

output_jar_name=tor_blacklist_waf-1.0.0-SNAPSHOT.jar

upload_result=$(aws s3api put-object --bucket stelligent-binary-artifact-repo \
                                     --key ${output_jar_name} \
                                     --body target/${output_jar_name})

version_id=$(echo ${upload_result} | jq '.VersionId' | tr -d '"')

echo version_id=${version_id}