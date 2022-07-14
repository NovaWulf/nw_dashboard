module Types
    class ModeledSignalType < Types::BaseObject
      field :id, ID, null: false
      field :model, String, null: false
      field :ts, Integer, null: false
      field :v, Float, null: false
      
      def ts
        object.starttime
      end
  
      def v
        object.value.round(4)
      end
    end
  end
  