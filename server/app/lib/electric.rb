class Electric
  include HTTParty
  base_uri 'raw.githubusercontent.com/electric-capital/crypto-ecosystems/master/data/ecosystems'

  def parsed_toml(token)
    chain = chain_name(token)
    mapping = file_mapping(chain)
    raise "No mapping found for #{chain}" unless mapping

    response = self.class.get(mapping)
    TOML::Parser.new(response.body).parsed
  end

  def sub_ecosystems(token)
    parsed_toml(token)['sub_ecosystems']
  end

  def repos(token)
    parsed_toml(token)['repo'].map {|r| r["url"]}
  end

  def file_mapping(chain)
    "/#{chain[0]}/#{chain}.toml"
  end

  def chain_name(token)
    case token.downcase
    when 'ada'
      'cardano'
    when 'algo'
      'algorand'
    when 'ar'
      'arweave'
    when 'avax'
      'avalanche'
    when 'btc'
      'bitcoin'
    when 'dot'
      'polkadot'
    when 'etc'
      'ethereum-classic'
    when 'eth'
      'ethereum'
    when 'fil'
      'filecoin'
    when 'luna'
      'terra'
    when 'near'
      'near-protocol'
    when 'sol'
      'solana'
    when 'xrp'
      'xrp'
    else
      token
    end
  end
end
