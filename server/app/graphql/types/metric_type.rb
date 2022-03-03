module Types
  class MetricType < Types::BaseObject
    field :id, ID, null: false
    field :metric, String, null: true
    field :token, String, null: true
    field :ts, Integer, null: false
    field :v, Float, null: false

    def ts
      object.timestamp.to_time.utc.to_i
    end

    def v
      object.value.round(4)
    end
  end
end
