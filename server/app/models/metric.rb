# == Schema Information
#
# Table name: metrics
#
#  id         :bigint           not null, primary key
#  metric     :string
#  timestamp  :date
#  token      :string
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Metric < ApplicationRecord
  self.filter_attributes = []

  scope :by_metric, ->(m) { where(metric: m) }
  scope :by_token, ->(t) { where(token: t) }
  scope :by_day, ->(d) { where(timestamp: d) }
  scope :mondays, -> { where('extract(dow from timestamp) = ?', 1) }
  scope :sundays, -> { where('extract(dow from timestamp) = ?', 0) }
  scope :oldest_first, -> { order(timestamp: :asc) }
end
