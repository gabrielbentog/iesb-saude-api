class ConsultationRoom < ApplicationRecord
  belongs_to :college_location
  belongs_to :specialty
end
