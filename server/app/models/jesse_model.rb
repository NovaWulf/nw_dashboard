# t.float :standard_error, null: false
# t.float :r_squared, null: false
# t.float :f_stat, null: false
# t.float :adj_r_squared, null: false
# t.integer :model_starttime, null: false
# t.integer :model_endtime, null: false

class JesseModel < ApplicationRecord
  has_many :jesse_model_weights, dependent: :destroy
  scope :newest_first, -> { order(model_endtime: :desc) }
end
