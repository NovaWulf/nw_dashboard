# == Schema Information
#
# Table name: modeled_signals
#
#  id                 :bigint           not null, primary key
#  in_sample_mean     :float
#  in_sample_sd_minus :float
#  in_sample_sd_plus  :float
#  resolution         :integer          not null
#  sigma              :float
#  starttime          :integer          not null
#  value              :float            not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  model_id           :string           not null
#
class ModeledSignal < ApplicationRecord
    self.filter_attributes = []
    scope :by_model, ->(m) { where(model_id: m) }
    scope :by_resolution, ->(r) { where(resolution: r) }
    scope :by_starttime, ->(t) { where(starttime: t) }
    scope :oldest_first, -> { order(timestamp: :asc) }
end
