class AuthenticationController < ApplicationController
  
  def login
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = AuthenticationService.encode(user)
      render json: { token: token, user: user }, status: :ok
    else
      render json: { errors: { id: 'unauthorized', title: 'Email ou senha inválidos' } }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
