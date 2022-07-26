class CreateBacktestModels < ActiveRecord::Migration[6.1]
  def change
    create_table :backtest_models do |t|
      t.timestamps
      t.string :model_id
      t.integer :sequence_number
      t.integer :version
    end
  end
end
