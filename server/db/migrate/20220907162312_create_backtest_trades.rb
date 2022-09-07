class CreateBacktestTrades < ActiveRecord::Migration[6.1]
  def change
    create_table :backtest_trades do |t|
      t.timestamps
      t.integer :email_time, null: true
      t.string :model_id, null: false
      t.float :signal_flag, null: false
      t.float :prev_signal_flag, null: false
      t.integer :cursor, null: false
      t.boolean :email_sent, null: false, default: false
    end
  end
end
