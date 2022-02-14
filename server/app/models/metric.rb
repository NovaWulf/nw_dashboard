class Metric < ApplicationRecord
  self.filter_attributes = []

  scope :by_metric, ->(m) { where(metric: m) }
  scope :by_token, ->(t) { where(token: t) }
  scope :by_day, ->(d) { where(timestamp: d) }
  scope :mondays, -> { where('extract(dow from timestamp) = ?', 1) }
  scope :oldest_first, -> { order(timestamp: :asc) }
end
