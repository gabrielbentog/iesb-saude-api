class Specialty < ApplicationRecord
  has_many :location_specialties, dependent: :destroy
  has_many :college_locations, through: :location_specialties

  validates :name, presence: true
end
