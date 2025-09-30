# app/serializers/intern_serializer.rb
class InternSerializer < BaseSerializer
  attributes :id,
             :name,
             :specialty,
             :avatar_url,
             :appointments_completed,
             :appointments_scheduled,
             :semester,
             :college_location,
             :status,
             :performance

  def specialty
    object&.specialty&.name
  end

  def avatar_url
    object.avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_path(object.avatar, only_path: true) : nil
  end

  def appointments_completed
    object.appointments_as_intern.where(status: :completed).count
  end

  def appointments_scheduled
    object.appointments_as_intern.where(status: [:admin_confirmed, :patient_confirmed]).count
  end

  def status
    object.active? ? 'Ativo' : 'Inativo'
  end

  def performance
    # Exemplo bobo: % de consultas concluídas sobre total atribuídas
    total = appointments_completed + appointments_scheduled
    total.zero? ? 0 : ((appointments_completed.to_f / total) * 100).round
  end

  def college_location
    object.college_location&.name
  end
end
