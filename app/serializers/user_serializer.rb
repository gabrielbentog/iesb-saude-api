class UserSerializer < BaseSerializer
  attributes :id, :name, :email, :cpf, :phone, :registration, :college_location_id, :semester, :registration_code, :created_at, :updated_at, :profile, :theme_preference

  def profile
    profile = object.profile
    if profile
      {
        id: profile.id,
        name: profile.name,
        users_count: profile.users_count
      }
    end
  end

  # def avatar_url
  #   return nil unless object.avatar.attached?

  #   # Use only_path to avoid generating full URL which can trigger extra route/object serialization
  #   Rails.application.routes.url_helpers.rails_blob_path(object.avatar, only_path: true)
  # end
end
