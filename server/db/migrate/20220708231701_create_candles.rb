class CreateCandles < ActiveRecord::Migration[6.1]
  def change
    create_table :candles do |t|

      t.timestamps
      t.datetime :starttime, null: false
      t.string :pair, null: false
      t.string :exchange, null: false
      t.integer :resolution, null: false
      t.float :open, null: false
      t.float :close, null: false
      t.float :high, null: false
      t.float :low, null: false
      t.float :volume, null: false

    end
  end
end
