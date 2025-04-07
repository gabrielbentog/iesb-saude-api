class ConsultationRoom < ApplicationRecord
  belongs_to :college_location
  belongs_to :specialty

  has_many :appointments, dependent: :destroy

  validates :name, presence: true
end
