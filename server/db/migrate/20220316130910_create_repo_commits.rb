class CreateRepoCommits < ActiveRecord::Migration[6.1]
  def change
    create_table :repo_commits do |t|
      t.date :day
      t.integer :count
      t.references :repo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
