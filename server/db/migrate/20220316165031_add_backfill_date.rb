class AddBackfillDate < ActiveRecord::Migration[6.1]
  def change
    add_column :repos, :backfilled_at, :datetime
  end
end
