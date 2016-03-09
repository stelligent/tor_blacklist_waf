require 'aws-sdk'
require 'set'
require 'aws-sdk-utils'

class WafIpSetUpdater


  def update(ip_set_name:, cidrs:)
    waf = Aws::WAF::Client.new

    ip_set_id = WafUtil::get_ipset_id_by_name ip_set_name

    get_ip_set_response = waf.get_ip_set(ip_set_id: ip_set_id)

    existing_cidrs = get_ip_set_response.ip_set.ip_set_descriptors.map { |descriptor| descriptor.value}

    changes = WafIpSetUpdater::compute_ip_set_changes existing_cidrs: existing_cidrs,
                                                      new_cidrs: cidrs

    get_change_token_response = waf.get_change_token
    update_ip_set_response = waf.update_ip_set ip_set_id: ip_set_id,
                                               change_token: get_change_token_response.change_token,
                                               updates: changes
  end

  # you probably shouldn't need to call me, but exposed for testing
  def self.compute_ip_set_changes(existing_cidrs:,new_cidrs:)
    new_cidrs_set = Set.new(new_cidrs)
    existing_cidrs_set = Set.new(existing_cidrs)

    additions = new_cidrs_set - existing_cidrs_set
    removals = existing_cidrs_set - new_cidrs_set

    updates = removals.map do |removal|
      {
        action: 'DELETE',
        ip_set_descriptor: {
            type: 'IPV4',
            value: removal
        }
      }
    end

    updates += additions.map do |addition|
      {
        action: 'INSERT',
        ip_set_descriptor: {
            type: 'IPV4',
            value: addition
        }
      }
    end
    updates
  end

end