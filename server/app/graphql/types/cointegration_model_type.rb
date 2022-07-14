module Types
    class CointegrationModelType < Types::BaseObject
      field :id, ID, null: false
      field :model_id, String, null: false
      field :in_sample_mean, Float, null: false
      field :in_sample_sd, Float, null: false
    end
  end
  