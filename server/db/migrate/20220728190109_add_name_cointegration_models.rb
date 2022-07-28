class AddNameCointegrationModels < ActiveRecord::Migration[6.1]
  def change
    add_column :cointegration_models, :name, :string
  end
end
