# t.string :uuid
# t.integer :timestamp
# t.string :ecdet
# t.string :spec
# t.float :cv_10_pct
# t.float :cv_5_pct
# t.float :cv_1_pct
# t.float :test_stat
# t.float :top_eig
# t.integer :resolution
# t.integer :model_starttime
# t.integer :model_endtime
class CointegrationModel < ApplicationRecord
    self.filter_attributes = []
    scope :newest_first, -> { order(model_endtime: :desc) }
  end