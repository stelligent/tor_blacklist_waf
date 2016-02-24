require 'spec_helper'
require 'waf_ip_set_updater'
require 'waf_util'
require 'tor_waf_blacklister'

describe 'waf oriented objects' do

  #if you keep running this, things will get expensive - 5$ per webacl and 1$ per rule
  before(:all) do
    # @stack_name = stack(stack_name: 'waftesting',
    #                     path_to_stack: 'spec/cfndsl_test_templates/basic_wafcfndsl.rb')
  end

  describe 'get_ipset_id_by_name' do
    context 'ipset with name has been created' do
      it 'returns an id' do
        ipset_id = WafUtil::get_ipset_id_by_name('torExitPointIpSet')
        puts ipset_id

        #this is too specific for general runs, but cost is going to stop us anyways
        expect(ipset_id).to eq '343c8ecf-6b24-459c-bbd1-06cf7cb653c4'
      end
    end

    context 'ipset without name has not been created' do
      it 'raises exception' do
        expect {
          WafUtil::get_ipset_id_by_name('somethingthatcouldnotpossiblyexist')
        }.to raise_error 'ipset somethingthatcouldnotpossiblyexist not found'
      end
    end
  end

  describe 'compute_ip_set_changes' do
    context 'no changes' do
      it 'returns empty array' do
        existing_cidrs = %w(1.2.3.4/32 5.6.7.8/32)
        new_cidrs = %w(1.2.3.4/32 5.6.7.8/32)
        changes = WafIpSetUpdater::compute_ip_set_changes existing_cidrs: existing_cidrs,
                                                  new_cidrs: new_cidrs
        expect(changes).to eq []
      end

    end

    context 'removals' do
      it 'returns array with DELETE for missing cidr' do
        existing_cidrs = %w(1.2.3.4/32 5.6.7.8/32)
        new_cidrs = %w(1.2.3.4/32)
        changes = WafIpSetUpdater::compute_ip_set_changes existing_cidrs: existing_cidrs,
                                                          new_cidrs: new_cidrs
        expect(changes).to eq [
            {
                action: 'DELETE',
                ip_set_descriptor: {
                    type: 'IPV4',
                    value: '5.6.7.8/32'
                }
            }
        ]
      end

    end

    context 'additions' do
      it 'returns array with INSERT for extra cidr' do
        existing_cidrs = %w(1.2.3.4/32 5.6.7.8/32)
        new_cidrs = %w(1.2.3.4/32 9.8.7.6/32)
        changes = WafIpSetUpdater::compute_ip_set_changes existing_cidrs: existing_cidrs,
                                                          new_cidrs: new_cidrs
        expect(changes).to eq [
            {
                action: 'DELETE',
                ip_set_descriptor: {
                    type: 'IPV4',
                    value: '5.6.7.8/32'
                }
            },
            {
                action: 'INSERT',
                ip_set_descriptor: {
                    type: 'IPV4',
                    value: '9.8.7.6/32'
                }
            }
        ]
      end
    end
  end


  # context 'fake list of 2 ip addresses fetched from mock tor' do
  #
  #   it 'updates the ipset to have only the 2 addresses' do
  #     blacklister = TorWafBlacklister.new
  #
  #     mock_fetcher = double('TorExitPointFetcher')
  #     expect(mock_fetcher).to receive(:fetch).and_return(%w(128.0.0.0 155.55.0.0))
  #     expect(blacklister).to receive(:fetcher) { mock_fetcher }
  #
  #     blacklister.update_blacklist ip_set_name: 'torExitPointIpSet'
  #
  #     #awspec doesnt support waf yet
  #     #expect(ip_set('torExitPointIpSet')).to eq %w(128.0.0.0 155.55.0.0)
  #   end
  #
  # end

  after(:all) do
    # cleanup(@stack_name)
  end
end