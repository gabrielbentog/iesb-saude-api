class Api::AppointmentStatusHistoriesController < Api::ApiController
  # GET /api/appointment/:id/appointment_status_histories
  def index
    @appointment_status_histories = AppointmentStatusHistory
    .includes(changed_by: :profile)
    .where(appointment_id: params[:appointment_id])
    .order(changed_at: :desc)
    render json: @appointment_status_histories, each_serializer: AppointmentStatusHistorySerializer
  end
end
