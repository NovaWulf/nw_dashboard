module Types
  class ModeledSignalType < Types::BaseObject
    field :id, ID, null: false
    field :model, String, null: false
    field :ts, Integer, null: false
    field :v, Float, null: false
    field :is, Boolean, null: false
    def ts
      object.starttime
    end

    def v
      object.value.round(4)
    end

    def is
      object.in_sample
    end
  end
end
