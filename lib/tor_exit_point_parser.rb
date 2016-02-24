class TorExitPointParser

  def ip_addresses(exit_address_records)
    exit_address_records.split("\n")
                        .select { |line| line.match /^ExitAddress.*$/ }
                        .map { |record| record.split(' ')[1] }
                        .uniq
  end
end