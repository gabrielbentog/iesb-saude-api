module Api
  class NotificationsController < ApiController
    before_action :set_notification, only: [:show, :update]

    # GET /api/notifications
    def index
      notifications = current_api_user.notifications.order(created_at: :desc)
      notifications = notifications.page(params[:page]).per(params[:per_page] || 20)
      render json: notifications, each_serializer: NotificationSerializer
    end

    # GET /api/notifications/:id
    def show
      render json: @notification, serializer: NotificationSerializer
    end

    # PATCH/PUT /api/notifications/:id
    # usado para marcar como lido / não lido
    def update
      if @notification.update(notification_params)
        render json: @notification, serializer: NotificationSerializer
      else
        render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # GET /api/notifications/unread_count
    def unread_count
      count = current_api_user.notifications.unread.count
      render json: { unread_count: count }
    end

    private

    def set_notification
      @notification = current_api_user.notifications.find(params[:id])
    end

    def notification_params
      params.require(:notification).permit(:read)
    end
  end
end
