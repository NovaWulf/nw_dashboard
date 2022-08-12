module Types
  class BacktestModelType < Types::BaseObject
    field :id, ID, null: false
    field :model_id, String, null: false
    field :version, Integer, null: false
    field :sequence_number, Integer, null: false
  end
end
