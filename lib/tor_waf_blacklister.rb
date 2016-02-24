require 'waf_ip_set_updater'
require 'tor_exit_point_fetcher'

class TorWafBlacklister

  def update_blacklist(ip_set_name:)
    addresses = fetcher.fetch

    WafIpSetUpdater.new.update(ip_set_name: ip_set_name,
                               cidrs: addresses.map { |addr| "#{addr}/32"})

    addresses
  end

  private

  def fetcher
    TorExitPointFetcher.new
  end
end