class CreateBacktests < ActiveRecord::Migration[6.1]
  def change
    create_table :backtests do |t|

      t.timestamps
      t.string :starttime, null: false
      t.string :model_id, null: false
      t.string :backtest_id, null: false
      t.string :strategy_id, null: false

    end
  end
end
