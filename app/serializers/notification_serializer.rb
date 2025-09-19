class NotificationSerializer < BaseSerializer
  attributes :id, :title, :body, :read, :data, :url, :appointment_id, :created_at

  belongs_to :appointment, if: -> { object.appointment.present? }
end
