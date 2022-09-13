# == Schema Information
#
# Table name: backtest_trades
#
#  id               :bigint           not null, primary key
#  cursor           :integer          not null
#  email_sent       :boolean          default(FALSE), not null
#  email_time       :integer
#  prev_signal_flag :float            not null
#  signal_flag      :float            not null
#  starttime        :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  model_id         :string           not null
#

class BacktestTrades < ApplicationRecord
  self.filter_attributes = []
  scope :by_model, ->(m) { where(model_id: m) }
  scope :oldest_first, -> { order(cursor: :asc) }
end
