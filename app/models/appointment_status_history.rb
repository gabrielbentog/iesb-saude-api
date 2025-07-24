class AppointmentStatusHistory < ApplicationRecord
  belongs_to :appointment
  belongs_to :changed_by, polymorphic: true, optional: true

  enum :from_status, Appointment.statuses, prefix: true
  enum :to_status,   Appointment.statuses, prefix: true
end
