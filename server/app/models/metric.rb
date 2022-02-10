class Metric < ApplicationRecord
  scope :by_metric, ->(m) { where(metric: m) }
  scope :by_token, ->(t) { where(token: t) }
  scope :by_day, ->(d) { where(timestamp: d) }
  scope :sundays, -> { where('extract(dow from timestamp) = ?', 0) }
end
