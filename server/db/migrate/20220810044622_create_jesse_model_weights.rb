class CreateJesseModelWeights < ActiveRecord::Migration[6.1]
  def change
    create_table :jesse_model_weights do |t|
      t.string :metric_name
      t.float :weight
      t.float :p_vals
      t.references :jesse_models, null: false, foreign_key: true
      t.timestamps
    end
  end
end
