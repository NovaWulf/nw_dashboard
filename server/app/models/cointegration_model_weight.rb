# == Schema Information
#
# Table name: cointegration_model_weights
#
#  id         :bigint           not null, primary key
#  asset_name :string
#  timestamp  :integer
#  uuid       :string
#  weight     :float
#
# Indexes
#
#  index_cointegration_model_weights_on_uuid_and_asset_name  (uuid,asset_name) UNIQUE
#
class CointegrationModelWeight < ApplicationRecord
    #belongs_to :cointegration_model
    scope :by_asset, ->(p) { where(asset_name: p) }
    scope :order_by_id, -> { order(id: :asc) }
    #scope :by_model, ->(uuid) { joins(:cointegration_model).where(cointegration_models: {uuid: uuid})}
end
