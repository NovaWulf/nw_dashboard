class VolumeFetcher < MessariDataFetcher
  def initialize(token:)
    super(token: token, metric: 'volume')
  end
end
