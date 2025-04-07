class CollegeLocation < ApplicationRecord
  has_many :location_specialties, dependent: :destroy
  has_many :specialties, through: :location_specialties

  validates :name, presence: true
end
