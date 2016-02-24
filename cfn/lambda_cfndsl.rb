require 'json'
CloudFormation {
  Description 'Create Lambda function to update a WAF with Tor blacklist'

  Parameter('ipSetId') {
    String
  }

  Lambda_Function('lambdaFunction') {
    Handler 'JRubyHandlerWrapper::handler'
    Runtime 'java8'
    Timeout 240
    MemorySize 256
    Role FnGetAtt('lambdaExecutionRole', 'Arn')
    Code({
      'S3Bucket' => 'stelligent-binary-artifact-repo',
      'S3Key' => 'tor_blacklist_waf-1.0.0-SNAPSHOT.jar',
      'S3ObjectVersion' => 'bO3b.AJtEATNC5DMo25_4dRvmbuArIRT'
    })
  }

  # adding a scheduled execution only available from console????
  # Lambda_Permission('eventsPermission') {
  #   Action 'lambda:InvokeFunction'
  #   FunctionName Ref('lambdaFunction')
  #   Principal 'events.amazonaws.com'
  #
  #   SourceAccount ''
  #   SourceArn ''
  # }

  IAM_Role('lambdaExecutionRole') {
    AssumeRolePolicyDocument(JSON.load <<-END
      {
        "Statement":[
          {
            "Action":[
              "sts:AssumeRole"
            ],
            "Effect":"Allow",
            "Principal":{
              "Service":[
                "lambda.amazonaws.com"
              ]
            }
          }
        ],
        "Version":"2012-10-17"
      }
    END
    )

    Policies([
      {
        'PolicyName' => 'UpdateIpset',
        'PolicyDocument' => (JSON.load <<-END
          {
            "Statement":[
              {
                "Action":[
                  "waf:UpdateIPSet",
                  "waf:GetIPSet"
                ],
                "Effect":"Allow",
                "Resource": {
                  "Fn::Join": [ "", ["arn:aws:waf::", {"Ref":"AWS::AccountId"}, ":ipset/", {"Ref": "ipSetId"} ]]
                }
              },
              {
                "Action":[
                  "waf:ListIPSets",
                  "waf:GetChangeToken*"
                ],
                "Effect":"Allow",
                "Resource":"*"
              },
              {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:logs:*:*:*"
              }
            ],
            "Version":"2012-10-17"
          }
        END
        )
      }
    ])
  }

  Output(:arn,
         FnGetAtt('lambdaFunction', 'Arn'))
}