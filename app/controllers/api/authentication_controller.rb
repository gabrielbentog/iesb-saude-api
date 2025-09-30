class Api::AuthenticationController < Api::ApiController
  skip_before_action :authenticate_api_user!, only: [:login]

  # POST /api/login
  def login
    email = user_params[:email]
    password = user_params[:password]

    render json: { error: 'E-mail e senha são obrigatórios' }, status: :bad_request if email.blank? || password.blank?

    user = User.find_by(email: email)

    if user && user.valid_password?(password)
      auth_token = user.create_new_auth_token.try(:[], 'Authorization')
      response.set_header('Authorization', auth_token)
      render json: { token: auth_token, user: UserSerializer.new(user) }, status: :ok
    else
      render json: { error: 'E-mail ou senha inválidos' }, status: :unauthorized
    end
  end

  def user_params
    params.permit(:email, :password)
  end
end
