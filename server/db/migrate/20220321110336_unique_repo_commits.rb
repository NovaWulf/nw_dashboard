class UniqueRepoCommits < ActiveRecord::Migration[6.1]
  def change
    # some corrupt data
    RepoCommit.where('day > ?', 3.weeks.ago).delete_all
    # remove dupes
    columns_that_make_record_distinct = %i[repo_id day]
    distinct_records = RepoCommit.select('MIN(id) as id').group(columns_that_make_record_distinct)
    RepoCommit.where.not(id: distinct_records).destroy_all
    add_index :repo_commits, %i[repo_id day], unique: true
  end
end
