class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :transform_params
  before_action :authenticate_api_user!

  def transform_params
    request.parameters.deep_transform_keys! { |key| key.to_s.underscore.to_sym }
  end
end
