class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  def authenticate_request!
    token = request.headers.try(:[], "Authorization")
    user_id = AuthenticationService.decode(token).try(:[], :user_id)
    if user_id
      @current_user = User.find(user_id)
    else
      render json: { errors: ['Unauthorized'] }, status: :unauthorized
    end
  end
end
