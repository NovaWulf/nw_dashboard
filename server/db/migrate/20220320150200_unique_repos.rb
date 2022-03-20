class UniqueRepos < ActiveRecord::Migration[6.1]
  def change
    # remove dupes
    columns_that_make_record_distinct = %i[user name token]
    distinct_records = Repo.select('MIN(id) as id').group(columns_that_make_record_distinct)
    Repo.where.not(id: distinct_records).destroy_all

    add_index :repos, %i[user name token], unique: true
  end
end
