class Api::AppointmentsController < Api::ApiController
  before_action :set_appointment, only: %i[ show update destroy confirm cancel reject]

  # GET /api/appointments
  def index
    specialty_id = current_api_user.specialty_id
    @appointments = Appointment.all
    @appointments = @appointments.where(user_id: current_api_user.id) if ['Paciente', 'Estagiário'].include?(current_api_user.profile.name)
    @appointments = @appointments.joins(:time_slot).where(time_slots: { specialty_id: specialty_id }) if specialty_id.present?
    @appointments = @appointments.apply_filters(params)
    @appointments = @appointments.order(created_at: :desc, start_time: :asc)
    meta = generate_meta(@appointments)

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

  # GET /api/appointments/next
  def next
    specialty_id = current_api_user.specialty_id
    @appointments = Appointment.joins(:time_slot).where.not(status: [:pending, :cancelled_by_admin, :rejected, :patient_cancelled])
    @appointments = @appointments.where(time_slots: { specialty_id: specialty_id }) if specialty_id.present?
    @appointments = @appointments.where(
      '(appointments.date > ?) OR (appointments.date = ? AND appointments.start_time > ?)',
      Date.current, Date.current, Time.current
    )
    @appointments = @appointments.where(user_id: current_api_user.id) if ['Paciente', 'Estagiário'].include?(current_api_user.profile.name)
    @appointments = @appointments.apply_filters(params)

    meta = {
      pagination: {
        total_count: @appointments.total_count,
        total_pages: @appointments.total_pages,
        current_page: @appointments.current_page,
        per_page: @appointments.limit_value
      }
    }

    render json: @appointments, each_serializer: AppointmentSerializer, meta: meta
  end

  # PUT /api/appointments/:id/confirm
  def confirm
    if @appointment.update(status: :confirmed)
      render json: @appointment, serializer: AppointmentSerializer, status: :ok
    else
      render json: ErrorSerializer.serialize(@appointment.errors), status: :unprocessable_entity
    end
  end

  # PUT /api/appointments/:id/cancel
  def cancel
    if @appointment.update(status: :cancelled)
      render json: @appointment, serializer: AppointmentSerializer, status: :ok
    else
      render json: ErrorSerializer.serialize(@appointment.errors), status: :unprocessable_entity
    end
  end

  # PUT /api/appointments/:id/reject
  def reject
    if @appointment.update(status: :rejected)
      render json: @appointment, serializer: AppointmentSerializer, status: :ok
    else
      render json: ErrorSerializer.serialize(@appointment.errors), status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_appointment
    @appointment = Appointment.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def appointment_params
    params.expect(appointment: [ :time_slot_id, :user_id, :date, :start_time, :end_time, :status, :notes, :intern_id ])
  end
end
