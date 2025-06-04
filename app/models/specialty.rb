class Specialty < ApplicationRecord
  has_many :location_specialties, dependent: :destroy
  has_many :college_locations, through: :location_specialties
  has_many :consultation_rooms, dependent: :restrict_with_error
  has_many :users, dependent: :restrict_with_error

  validates :name, presence: true
end
