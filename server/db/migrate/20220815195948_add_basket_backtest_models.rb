class AddBasketBacktestModels < ActiveRecord::Migration[6.1]
  def change
    add_column :backtest_models, :basket, :string, default: 'OP_ETH'
  end
end
