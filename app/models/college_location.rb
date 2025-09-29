class CollegeLocation < ApplicationRecord
  has_many :location_specialties, dependent: :destroy
  has_many :specialties, through: :location_specialties
  has_many :consultation_rooms, dependent: :restrict_with_error
  has_many :interns, class_name: 'User', foreign_key: 'college_location_id', dependent: :nullify
  validates :name, presence: true
end
