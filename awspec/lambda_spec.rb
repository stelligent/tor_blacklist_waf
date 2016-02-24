require_relative 'spec_helper'

ENV['LAMBDA_FUNCTION_NAME'] = 'CloudFront-Lambda-Security-sgUpdaterLambdaFunction-CQS3T2H2QKZV'

describe lambda(ENV['LAMBDA_FUNCTION_NAME']) do
  it { should exist }
  its(:handler) { should eq 'JRubyHandlerWrapper::handler' }
  its(:runtime) { should eq 'java8' }
  its(:timeout) { should eq  240 }
  its(:memory_size) { should eq 512 }

  its(:role) {
    should_not eq nil
  }
end