class RepoLastFetched < ActiveRecord::Migration[6.1]
  def change
    add_column :repos, :last_fetched_at, :datetime
    add_column :repos, :error_fetching_at, :datetime
  end
end
