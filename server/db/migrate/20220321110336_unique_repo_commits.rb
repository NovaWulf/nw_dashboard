class UniqueRepoCommits < ActiveRecord::Migration[6.1]
  def change
    add_index :repo_commits, %i[repo_id day], unique: true
  end
end
