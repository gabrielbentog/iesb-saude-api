class Api::ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include LoggableRequest

  before_action :authenticate_api_user!
  skip_before_action :authenticate_api_user!, if: :devise_controller?
  before_action :transform_params
  after_action :camelize_response

  def transform_params
    request.parameters.deep_transform_keys! { |key| key.to_s.underscore.to_sym }
  end

  def generate_meta(collection, extra: {})
    {
      pagination: {
        total_count:  collection.total_count,
        total_pages:  collection.total_pages,
        current_page: collection.current_page,
        per_page:     collection.limit_value
      }
    }.merge(extra.symbolize_keys)
  end

  def camelize_response
    return unless response.media_type == 'application/json'

    body = response.body.presence && JSON.parse(response.body) rescue nil
    return unless body

    camelized = body.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    response.body = camelized.to_json
  end
end
