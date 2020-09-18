#!/usr/bin/env bash
export account_id=$(aws sts get-caller-identity | jq -r .Account)
export source_bucket=$(aws ssm get-parameter --name 'tf-docker-push-bucket' | jq -r .Parameter.Value)
export pipeline_name=$(aws ssm get-parameter --name 'tf-docker-push-pipeline' | jq -r .Parameter.Value)
export REGION='us-east-1'

rm -rf source.zip
zip -r source.zip . -x '*.terraform*'
aws s3 cp source.zip s3://${source_bucket}/source.zip
aws codepipeline start-pipeline-execution --name ${pipeline_name}
