class AppointmentStatusHistorySerializer < ActiveModel::Serializer
  attributes :id, :appointment_id, :from_status, :to_status, :changed_at, :changed_by

  def changed_by
    if object.changed_by
      {
        id: object.changed_by_id,
        name: object.changed_by.name,
        profile: object.changed_by.profile.name
      }
    else
      nil
    end
  end

  def from_status
    I18n.t("activerecord.attributes.appointment.status.#{object.from_status.to_s}") if object.from_status.present?
  end

  def to_status
    I18n.t("activerecord.attributes.appointment.status.#{object.to_status.to_s}") if object.to_status.present?
  end
end
