# == Schema Information
#
# Table name: modeled_signals
#
#  id         :bigint           not null, primary key
#  in_sample  :boolean          default(TRUE)
#  resolution :integer          not null
#  starttime  :integer          not null
#  value      :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :string           not null
#
# Indexes
#
#  index_modeled_signals_on_model_id_and_starttime  (model_id,starttime) UNIQUE
#
class ModeledSignal < ApplicationRecord
    self.filter_attributes = []
    scope :by_model, ->(m) { where(model_id: m) }
    scope :by_resolution, ->(r) { where(resolution: r) }
    scope :by_starttime, ->(t) { where(starttime: t) }
    scope :on_the_hour, -> { where('extract(minute from to_timestamp(starttime)) = ?', 0) }
    scope :at_noon, -> { where('extract(hour from to_timestamp(starttime)) = ?', 12) }
    scope :oldest_first, -> { order(starttime: :asc) }
end
