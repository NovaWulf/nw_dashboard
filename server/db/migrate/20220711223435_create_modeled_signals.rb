class CreateModeledSignals < ActiveRecord::Migration[6.1]
  def change
    create_table :modeled_signals do |t|
      t.timestamps
      t.integer :starttime, null: false
      t.string :model_id, null: false
      t.integer :resolution, null: false
      t.float :value, null: false
    end
  end
end
