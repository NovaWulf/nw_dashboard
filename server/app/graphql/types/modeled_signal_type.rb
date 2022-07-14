module Types
    class ModeledSignalType < Types::BaseObject
      field :id, ID, null: false
      field :model, String, null: false
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
  