class AddEpochBacktestModels < ActiveRecord::Migration[6.1]
  def change
    add_column :backtest_models, :epoch, :string, default: 'OP-ETH'
  end
end
