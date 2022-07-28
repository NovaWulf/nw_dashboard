class AddNameBacktestModels < ActiveRecord::Migration[6.1]
  def change
    add_column :backtest_models, :name, :string
  end
end
