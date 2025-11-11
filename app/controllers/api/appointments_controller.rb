class Api::AppointmentsController < Api::ApiController
  before_action :set_appointment, only: %i[ show update destroy confirm cancel reject]

  # GET /api/appointments
  def index
    specialty_id = current_api_user.specialty_id
    @appointments = Appointment.all
    @appointments = @appointments.where(user_id: current_api_user.id) if current_api_user.profile.name == 'Paciente'
    @appointments = @appointments.joins(:interns).where(users: { id: current_api_user.id }) if current_api_user.profile.name == 'Estagiário'
    @appointments = @appointments.joins(:time_slot).where(time_slots: { specialty_id: specialty_id }) if specialty_id.present?
    @appointments = @appointments.apply_filters(params)
    @appointments = @appointments.order(created_at: :desc, start_time: :asc)
    meta = generate_meta(@appointments)
    meta = meta.merge(meta_for_profile(current_api_user.profile.name))

    render json: @appointments, each_serializer: AppointmentSerializer, meta: meta
  end

  # GET /appointments/1
  def show
    if current_api_user.profile.name == 'Paciente' && @appointment.user_id != current_api_user.id
      render json: { error: 'Not authorized' }, status: :forbidden and return
    end

    if current_api_user.profile.name == 'Estagiário' && !@appointment.interns.exists?(id: current_api_user.id)
      render json: { error: 'Not authorized' }, status: :forbidden and return
    end

    render json: @appointment, serializer: AppointmentSerializer, status: :ok
  end

  # POST /appointments
  def create
    return render json: { error: 'Not authorized' }, status: :forbidden if current_api_user.profile.name == 'Estagiário'
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
    @appointments = Appointment.joins(:time_slot).where(status: [:patient_confirmed, :admin_confirmed])
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
    @appointment = Appointment.find(params.require(:id))
  end

  # Only allow a list of trusted parameters through.
  def appointment_params
    params.require(:appointment).permit(:time_slot_id, :user_id, :date, :start_time, :end_time, :status, :notes, intern_ids: [])
  end

  def meta_for_profile(profile_name)
    case profile_name
    when 'Paciente'
      next_appointment_count = Appointment
      .where(user_id: current_api_user.id)
      .where('(appointments.date > ?) OR (appointments.date = ? AND appointments.start_time > ?)', Date.current, Date.current, Time.current)
      .order(:date, :start_time).count

      completed_appointments_count = Appointment.where(status: :completed, user_id: current_api_user.id).count

      pending_confirmation = Appointment
      .where(user_id: current_api_user.id)
      .where(status: :admin_confirmed)
      .count

      { next_appointment_count: next_appointment_count, completed_appointments_count: completed_appointments_count, pending_confirmation: pending_confirmation }
    when 'Estagiário'
      next_appointment_count = Appointment.joins(:interns)
      .where(interns: { id: current_api_user.id })
      .where('(appointments.date > ?) OR (appointments.date = ? AND appointments.start_time > ?)', Date.current, Date.current, Time.current)
      .order(:date, :start_time).count

      completed_appointments_count = Appointment.joins(:interns)
      .where(interns: { id: current_api_user.id } )
      .where(status: :completed).count

      { next_appointment_count: next_appointment_count, completed_appointments_count: completed_appointments_count }
    when 'Gestor'
      { can_create: true, can_approve: true, can_cancel: true }
    else
      {}
    end
  end
end
