class CreateMetrics < ActiveRecord::Migration[6.1]
  def change
    create_table :metrics do |t|
      t.string :name
      t.datetime :timestamp
      t.float :value

      t.timestamps
    end
  end
end
