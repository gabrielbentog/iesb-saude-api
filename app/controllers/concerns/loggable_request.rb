# app/controllers/concerns/loggable_request.rb
module LoggableRequest
  extend ActiveSupport::Concern

  included do
    after_action :log_request_to_db
  end

  private

  def log_request_to_db
    RequestLog.create!(
      method: request.method,
      path: request.fullpath,
      controller: controller_name,
      action: action_name,
      params: request.filtered_parameters.except(:controller, :action),
      ip: request.remote_ip,
      user_id: current_api_user&.id
    )
  rescue => e
    Rails.logger.error("[LOG ERROR] #{e.class}: #{e.message}")
  end
end