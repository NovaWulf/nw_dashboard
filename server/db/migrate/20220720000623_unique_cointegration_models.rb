class UniqueCointegrationModels < ActiveRecord::Migration[6.1]
  def change
    add_index :cointegration_models, %i[uuid], unique: true
  end
end
