class UniqueRepoCommits < ActiveRecord::Migration[6.1]
  def change
    # some corrupt data
    RepoCommit.where('day > ?', 3.weeks.ago).delete_all
    add_index :repo_commits, %i[repo_id day], unique: true
  end
end
