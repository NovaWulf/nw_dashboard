# == Schema Information
#
# Table name: jesse_models
#
#  id              :bigint           not null, primary key
#  adj_r_squared   :float            not null
#  f_stat          :float            not null
#  model_endtime   :integer          not null
#  model_starttime :integer          not null
#  r_squared       :float            not null
#  standard_error  :float            not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class JesseModel < ApplicationRecord
  has_many :jesse_model_weight, dependent: :destroy
  scope :newest_first, -> { order(model_endtime: :desc) }
end
