require 'aws-sdk'
class CloudformationConverger


  def converge(stack_name:,stack_path:,parameters:nil)

    cfn_parameters = []
    unless parameters.nil?
      parameters.each do |k, v|
        cfn_parameters << {
            parameter_key: k,
            parameter_value: v
        }
      end
    end

    cloudformation_client = Aws::CloudFormation::Client.new
    resource = Aws::CloudFormation::Resource.new(client: cloudformation_client)
    if resource.stacks.find {|stack| stack.name == stack_name }
      stack = resource.stack(stack_name)
      begin
        stack.update(template_body: IO.read(stack_path),
                     capabilities: %w(CAPABILITY_IAM),
                     parameters: cfn_parameters)
      rescue Exception => error
        if error.to_s =~ /No updates are to be performed/
          puts 'no updates necessary'
        else
          raise error
        end
      end

    else


      stack = resource.create_stack(stack_name: stack_name,
                                    template_body: IO.read(stack_path),
                                    capabilities: %w(CAPABILITY_IAM),
                                    parameters: cfn_parameters)
    end

    stack.wait_until(max_attempts:100, delay:15) do |stack|
      stack.stack_status =~ /COMPLETE/ or stack.stack_status =~ /FAILED/
    end

    if stack.stack_status =~ /FAILED/
      raise "#{stack_name} failed to converge: #{stack.stack_status}"
    end

    stack.outputs.inject({}) do |hash, output|
      hash[output.output_key] = output.output_value
      hash
    end
  end
end