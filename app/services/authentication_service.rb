class AuthenticationService
  SECRET_KEY = Rails.application.credentials.secret_key_base

  # Gera um token JWT
  def self.encode(user)
    user_id = user.id    
    payload = { user_id: user_id, exp: 2.hours.from_now.to_i }
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodifica o token JWT
  def self.decode(token)
    token = token&.split(' ')&.last
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end
end
