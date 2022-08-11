class AddInterpolatedToCandles < ActiveRecord::Migration[6.1]
  def change
    add_column :candles, :interpolated, :boolean, default: false
  end
end
