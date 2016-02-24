require 'spec_helper'
require 'tor_exit_point_fetcher'

describe TorExitPointFetcher do

  context 'Tor is up' do
    it 'returns array of all exit point IP addresses' do
      fetcher = TorExitPointFetcher.new
      addresses = fetcher.fetch
      puts addresses
      expect(addresses.size).to be > 0

      #expect(addresses.uniq.size).to eq addresses.size
    end
  end
end