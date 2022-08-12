class CreateJesseModels < ActiveRecord::Migration[6.1]
  def change
    create_table :jesse_models do |t|
      t.float :standard_error, null: false
      t.float :r_squared, null: false
      t.float :f_stat, null: false
      t.float :adj_r_squared, null: false
      t.integer :model_starttime, null: false
      t.integer :model_endtime, null: false
      t.timestamps
    end
  end
end
