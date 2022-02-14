class Electric
  include HTTParty
  base_uri 'raw.githubusercontent.com/electric-capital/crypto-ecosystems/master/data/ecosystems'

  def sub_ecosystems(chain)
    mapping = file_mapping(chain)
    raise "No mapping found for #{chain}" unless mapping

    response = self.class.get(mapping)
    result = TOML::Parser.new(response.body).parsed
    result['sub_ecosystems']
  end

  def file_mapping(chain)
    c = electric_mapping(chain)
    "/#{c[0]}/#{c}.toml"
  end

  def electric_mapping(chain)
    case chain
    when 'file-coin'
      'filecoin'
    when 'ripple'
      'xrp'
    else
      chain
    end
  end
end
