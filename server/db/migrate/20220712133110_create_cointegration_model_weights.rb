class CreateCointegrationModelWeights < ActiveRecord::Migration[6.1]
  def change
    create_table :cointegration_model_weights do |t|

      t.string :uuid
      t.integer :timestamp
      t.string :asset_name 
      t.float :weight

    end
  end
end
