module Types
  class MetricType < Types::BaseObject
    field :id, ID, null: false
    field :n, String, null: true
    field :ts, Integer, null: false
    field :v, Float, null: false

    def n
      object.name
    end

    def ts
      object.timestamp.to_time.to_i
    end

    def v
      object.value.round(4)
    end
  end
end
