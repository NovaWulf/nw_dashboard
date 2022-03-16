class CreateRepos < ActiveRecord::Migration[6.1]
  def change
    create_table :repos do |t|
      t.string :token
      t.string :user
      t.string :name

      t.timestamps
    end
  end
end
