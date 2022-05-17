module Displayers
  class VolumeDisplayer < WeeklySumDisplayer
  def initialize(token:)
    super(token: token, metric: 'volume')
  end
end
end