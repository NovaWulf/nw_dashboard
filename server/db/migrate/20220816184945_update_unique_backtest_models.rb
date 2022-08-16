class UpdateUniqueBacktestModels < ActiveRecord::Migration[6.1]
  def change
    remove_index :backtest_models, %i[version sequence_number]
    add_index :backtest_models, %i[version sequence_number basket], unique: true
  end
end
