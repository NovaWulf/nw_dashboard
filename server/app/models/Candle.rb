# == Schema Information
#
# Table name: candles
#
#  id         :bigint           not null, primary key
#  close      :float            not null
#  exchange   :string           not null
#  high       :float            not null
#  low        :float            not null
#  open       :float            not null
#  pair       :string           not null
#  resolution :integer          not null
#  starttime  :integer          not null
#  volume     :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_candles_on_exchange_and_starttime_and_pair_and_resolution  (exchange,starttime,pair,resolution) UNIQUE
#
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
    scope :oldest_first, -> { order(starttime: :asc) }
  end
  
