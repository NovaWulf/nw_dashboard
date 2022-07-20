class CreateBacktest < ActiveRecord::Migration[6.1]
  def change
    create_table :backtest_transactions do |t|
      t.timestamps
      t.integer :starttime, null: false
      t.string :model_id, null: false
      t.integer :resolution, null: false
      t.float :delta, null: false
      t.string :asset_name, null: false
    end
  end
end
