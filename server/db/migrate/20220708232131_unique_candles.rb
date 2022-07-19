class UniqueCandles < ActiveRecord::Migration[6.1]
  def change
    add_index :candles, %i[exchange starttime pair resolution], unique: true
  end
end
