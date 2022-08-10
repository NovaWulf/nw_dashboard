# t.string :metric_name
# t.float :p_val
# t.float :weight
# t.references :jesse_models, null: false, foreign_key: true

class JesseModelWeight < ApplicationRecord
  belongs_to :jesse_models
end
