    # Candle Table Schema:
    #   t.timestamps
    #   t.datetime :starttime, null: false
    #   t.string :pair, null: false
    #   t.string :exchange, null: false
    #   t.integer :resolution, null: false
    #   t.float :open, null: false
    #   t.float :close, null: false
    #   t.float :high, null: false
    #   t.float :low, null: false
    #   t.float :volume, null: false
class Candle < ApplicationRecord
    self.filter_attributes = []
    scope :by_exchange, ->(m) { where(exchange: m) }
    scope :by_pair, ->(p) { where(pair: p) }
    scope :by_resolution, ->(r) { where(resolution: r) }
    scope :by_starttime, ->(t) { where(starttime: t) }
    scope :by_date, -> (d) { where('DATE(timestamp)':d) }
    scope :oldest_first, -> { order(timestamp: :asc) }
  end
  