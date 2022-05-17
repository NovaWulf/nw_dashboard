class SantimentActivityDisplayer < WeeklySumDisplayer
  def initialize(token:)
    super(token: token, metric: 'dev_activity')
  end
end
