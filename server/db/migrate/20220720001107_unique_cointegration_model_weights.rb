class UniqueCointegrationModelWeights < ActiveRecord::Migration[6.1]
  def change
    add_column :cointegration_model_weights,  %i[uuid asset_anem], unique: true
  end
end
