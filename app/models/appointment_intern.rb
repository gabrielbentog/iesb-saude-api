class AppointmentIntern < ApplicationRecord
  belongs_to :appointment
  belongs_to :intern, class_name: 'User'
end
