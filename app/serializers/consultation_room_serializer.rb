class ConsultationRoomSerializer < ActiveModel::Serializer
  attributes :id, :name, :active
  has_one :college_location
  has_one :specialty
end
