class CreateJesseModelsWeights < ActiveRecord::Migration[6.1]
  def change
    create_table :jesse_models_weights do |t|
      t.string :metric_name
      t.float :p_val
      t.float :weight
      t.references :jesse_models, null: false, foreign_key: true
      t.timestamps
    end
  end
end
