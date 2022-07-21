# t.timestamps
# t.string :starttime, null: false
# t.string :model_id, null: false
# t.boolean :in_sample, null: false
# t.float :pnl, null: false

class Backtest < ApplicationRecord
  self.filter_attributes = []
  scope :by_exchange, -> (m) { where(exchange: m) }
  scope :by_pair, -> (p) { where(pair: p) }
  scope :by_resolution, ->(r) { where(resolution: r) }
  scope :by_starttime, ->(t) { where(starttime: t) }
  scope :by_date, -> (d) { where('DATE(timestamp)':d) }
  scope :oldest_first, -> { order(starttime: :asc) }
end