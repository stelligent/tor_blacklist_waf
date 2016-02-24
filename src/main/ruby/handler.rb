$LOAD_PATH << 'uri:classloader:/'
require 'tor_waf_blacklister'

TorWafBlacklister.new.update_blacklist ip_set_name: 'torExitPointIpSet'
