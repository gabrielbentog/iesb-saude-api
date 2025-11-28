class ConsultationRoom < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :college_location
  belongs_to :specialty

  has_many :appointments, dependent: :destroy

  validates :name, presence: true
end
