# == Schema Information
#
# Table name: jesse_model_weights
#
#  id              :bigint           not null, primary key
#  metric_name     :string
#  p_vals          :float
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  jesse_models_id :bigint
#
# Indexes
#
#  index_jesse_model_weights_on_jesse_models_id  (jesse_models_id)
#
# Foreign Keys
#
#  fk_rails_...  (jesse_models_id => jesse_models.id)
#

class JesseModelWeight < ApplicationRecord
  belongs_to :jesse_model, optional: true
  ->(p) { where(asset_name: p) }
  scope :by_id, ->(id) { where("jesse_models_id=#{id}") }
end
