module Types
  class CandleType < Types::BaseObject
    field :id, ID, null: false
    field :ts, String, null: false
    field :v, Float, null: false

    def ts
      object.starttime
    end

    def v
      object.close.round(4)
    end
  end
end
