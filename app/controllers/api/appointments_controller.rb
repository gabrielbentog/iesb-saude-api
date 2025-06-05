class Api::AppointmentsController < Api::ApiController
  before_action :set_appointment, only: %i[ show update destroy ]

  # GET /api/appointments
  def index
    @appointments = Appointment.all.apply_filters(params)
    meta = {
      total_count: @appointments.total_count,
      total_pages: @appointments.total_pages,
      current_page: @appointments.current_page,
      per_page: @appointments.limit_value
    }

    render json: @appointments, each_serializer: AppointmentSerializer, meta: meta
  end

  # GET /appointments/1
  def show
    render json: @appointment, serializer: AppointmentSerializer, status: :ok
  end

  # POST /appointments
  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      render json: @appointment, serializer: AppointmentSerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@appointment.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /appointments/1
  def update
    if @appointment.update(appointment_params)
      render json: @appointment, serializer: AppointmentSerializer, status: :ok
    else
      render json: ErrorSerializer.serialize(@appointment.errors), status: :unprocessable_entity
    end
  end

  # DELETE /appointments/1
  def destroy
    @appointment.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_appointment
    @appointment = Appointment.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def appointment_params
    params.expect(appointment: [ :time_slot_id, :user_id, :date, :start_time, :end_time, :status, :notes ])
  end
end
