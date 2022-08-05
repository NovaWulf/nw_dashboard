class AddLogPricesToCointegrationModels < ActiveRecord::Migration[6.1]
  def change
    add_column :cointegration_models, :log_prices, :boolean
  end
end
