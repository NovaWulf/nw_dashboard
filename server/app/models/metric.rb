class Metric < ApplicationRecord
  scope :by_name, ->(m) { where(name: m) }
  scope :by_day, ->(d) { where(timestamp: d) }
  scope :sundays, -> { where('extract(dow from timestamp) = ?', 0) }
end
