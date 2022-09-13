module Types
  class CointegrationModelWeightType < Types::BaseObject
    field :id, ID, null: false
    field :asset_name, String, null: false
    field :weight, Float, null: false
  end
end
