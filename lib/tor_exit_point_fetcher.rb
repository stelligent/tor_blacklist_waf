require 'open-uri'
require 'tor_exit_point_parser'

class TorExitPointFetcher
  TOR_EXIT_POINTS_ENDPOINT = 'https://check.torproject.org/exit-addresses'

  def fetch
    uri = URI.parse endpoint

    TorExitPointParser.new.ip_addresses uri.read
  end

  private

  def endpoint
    TOR_EXIT_POINTS_ENDPOINT
  end
end

