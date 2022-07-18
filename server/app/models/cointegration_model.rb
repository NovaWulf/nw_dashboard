# == Schema Information
#
# Table name: cointegration_models
#
#  id              :bigint           not null, primary key
#  cv_10_pct       :float
#  cv_1_pct        :float
#  cv_5_pct        :float
#  ecdet           :string
#  in_sample_mean  :float
#  in_sample_sd    :float
#  model_endtime   :integer
#  model_starttime :integer
#  resolution      :integer
#  spec            :string
#  test_stat       :float
#  timestamp       :integer
#  top_eig         :float
#  uuid            :string
#
class CointegrationModel < ApplicationRecord
    #has_many :cointegration_model_weight
    scope :by_asset, ->(p) { where(asset_name: p) }
    scope :newest_first, -> { order(model_endtime: :desc) }
end
