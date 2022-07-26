class AddInSampleModeledSignals < ActiveRecord::Migration[6.1]
  def change
    add_column :modeled_signals, :in_sample, :boolean, default: true
  end
end
