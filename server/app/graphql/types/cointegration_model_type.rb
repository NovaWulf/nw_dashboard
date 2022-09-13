module Types
  class CointegrationModelType < Types::BaseObject
    field :id, ID, null: false
    field :uuid, String, null: false
    field :in_sample_mean, Float, null: false
    field :in_sample_sd, Float, null: false
    field :model_endtime, Integer, null: false
    field :model_starttime, Integer, null: false
    field :test_stat, Float, null: false
    field :cv_1_pct, Float, null: false
  end
end
