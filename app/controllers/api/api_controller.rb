class Api::ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include LoggableRequest

  before_action :authenticate_api_user!
  skip_before_action :authenticate_api_user!, if: :devise_controller?
  before_action :underscore_params!
  before_action :touch_user_activity
  before_action :set_current_context
  after_action :camelize_response

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
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

  def touch_user_activity
    return if current_api_user.nil?

    if current_api_user.last_activity_at.nil? || current_api_user.last_activity_at < 5.minutes.ago
      current_api_user.update_column(:last_activity_at, Time.current)
    end
  end

  private

  def set_current_context
    Current.user       = current_api_user
    Current.request_id = request.uuid
  end
end
