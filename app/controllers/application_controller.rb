class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :transform_params

  def authenticate_request!
    token = request.headers.try(:[], "Authorization")
    user_id = AuthenticationService.decode(token).try(:[], :user_id)
    if user_id
      @current_user = User.find(user_id)
    else
      render json: { errors: ['Unauthorized'] }, status: :unauthorized
    end
  end

  def transform_params
    request.parameters.deep_transform_keys! { |key| key.to_s.underscore.to_sym }
  end
end
