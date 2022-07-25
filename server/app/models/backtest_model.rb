class BacktestModel < ApplicationRecord
  scope :by_version, ->(v) { where(version: v) }
  scope :oldest_first, -> { order(version: :asc) }
end
