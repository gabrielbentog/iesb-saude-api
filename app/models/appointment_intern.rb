class AppointmentIntern < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :appointment
  belongs_to :intern, class_name: 'User'
end
