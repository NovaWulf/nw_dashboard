# == Schema Information
#
# Table name: backtest_models
#
#  id              :bigint           not null, primary key
#  basket          :string           default("OP_ETH")
#  name            :string
#  sequence_number :integer          not null
#  version         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  model_id        :string           not null
#
# Indexes
#
#  index_backtest_models_on_version_and_sequence_number  (version,sequence_number) UNIQUE
#
class BacktestModel < ApplicationRecord
  scope :by_version, ->(v) { where(version: v) }
  scope :oldest_version_first, -> { order(version: :asc) }
  scope :oldest_sequence_number_first, -> {order(sequence_number: :asc)}
end
