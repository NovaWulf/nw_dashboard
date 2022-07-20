class UniqueCointegrationModelWeights < ActiveRecord::Migration[6.1]
  def change
    add_index :cointegration_model_weights, %i[model_id asset_name], unique: true
  end
end
