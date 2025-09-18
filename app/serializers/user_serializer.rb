class UserSerializer < BaseSerializer
  attributes :id, :name, :email, :cpf, :phone, :registration, :registration_code, :created_at, :updated_at, :profile, :theme_preference

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
end
