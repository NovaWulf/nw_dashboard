class CreateCointegrationModels < ActiveRecord::Migration[6.1]
  def change
    create_table :cointegration_models do |t|

      t.string :uuid
      t.integer :timestamp
      t.string :ecdet
      t.string :spec
      t.float :cv_10_pct
      t.float :cv_5_pct
      t.float :cv_1_pct
      t.float :test_stat
      t.float :top_eig
      t.float :in_sample_mean
      t.float :in_sample_sd
      t.integer :resolution
      t.integer :model_starttime
      t.integer :model_endtime

    end
  end
end
