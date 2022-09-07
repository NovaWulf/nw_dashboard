class UniqueBacktestModels < ActiveRecord::Migration[6.1]
  def change
    add_index :backtest_models, %i[version sequence_number], unique: true
  end
end
