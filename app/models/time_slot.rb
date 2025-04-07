class TimeSlot < ApplicationRecord
  belongs_to :college_location
  belongs_to :specialty
  belongs_to :intern, class_name: 'User', optional: true
end
