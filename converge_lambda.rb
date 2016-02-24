#!/usr/bin/env ruby
require 'trollop'
require_relative 'lib/cloudformation_converger'
require_relative 'lib/waf_util'

opts = Trollop::options do
  opt :stack_name, '', type: :string, required: true
  opt :path, '', type: :string, required: true
end


ip_set_id = WafUtil::get_ipset_id_by_name('torExitPointIpSet')

outputs = CloudformationConverger.new.converge stack_name: opts[:stack_name],
                                               stack_path: opts[:path],
                                               parameters: { 'ipSetId' => ip_set_id }