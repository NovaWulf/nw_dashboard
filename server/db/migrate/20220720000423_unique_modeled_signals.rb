class UniqueModeledSignals < ActiveRecord::Migration[6.1]
  def change
    add_index :modeled_signals, %i[model_id starttime], unique: true
  end
end
