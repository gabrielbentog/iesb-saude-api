class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at, :updated_at, :profile

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
