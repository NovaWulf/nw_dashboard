class AddGithubIdToRepo < ActiveRecord::Migration[6.1]
  def change
    add_column :repos, :github_id, :integer
    add_column :repos, :canonical, :boolean, default: false
    # add_index :repos, :github_id, unique: true
  end
end
