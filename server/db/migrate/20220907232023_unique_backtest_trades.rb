class UniqueBacktestTrades < ActiveRecord::Migration[6.1]
  def change
    add_index :backtest_trades, %i[cursor model_id], unique: true
  end
end
