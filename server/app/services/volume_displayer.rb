class VolumeDisplayer < BaseService
  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def run
    Metric.by_token(token).by_metric('volume').mondays.oldest_first
  end
end
