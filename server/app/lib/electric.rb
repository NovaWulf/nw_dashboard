class Electric
  include HTTParty
  base_uri 'raw.githubusercontent.com/electric-capital/crypto-ecosystems/master/data/ecosystems'

  BLOCKCHAIN_MAPPING = {
    'ethereum' => '/e/ethereum',
    'bitcoin' => '/b/bitcoin'
  }

  def sub_ecosystems(chain)
    mapping = BLOCKCHAIN_MAPPING[chain]
    raise "No mapping found for #{chain}" unless mapping

    response = self.class.get(mapping + '.toml')
    result = TOML::Parser.new(response.body).parsed
    result['sub_ecosystems']
  end
end
