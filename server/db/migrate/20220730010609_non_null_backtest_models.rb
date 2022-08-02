class NonNullBacktestModels < ActiveRecord::Migration[6.1]
  def change
    change_column_null :backtest_models, :model_id, false
    change_column_null :backtest_models, :sequence_number, false
    change_column_null :backtest_models, :version, false
  end
end
