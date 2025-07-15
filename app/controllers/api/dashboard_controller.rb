# app/controllers/api/dashboard_controller.rb
class Api::DashboardController < Api::ApiController
  # GET /api/dashboard/kpis
  def kpis
    today          = Date.current
    last_week_day  = today - 7.days
    specialty_id = current_api_user.specialty_id

    # 1. Appointments today + variation vs. same weekday last week
    appointments_today       = Appointment.joins(:time_slot).where(date: today, time_slots: { specialty_id: specialty_id }).count
    appointments_last_week   = Appointment.joins(:time_slot).where(date: last_week_day, time_slots: { specialty_id: specialty_id }).count
    percent_change =
      if appointments_last_week.zero?
        0.0
      else
        ((appointments_today - appointments_last_week) * 100.0 / appointments_last_week).round(1)
      end

    # 2. Total appointments, split by status
    total_appointments  = Appointment.joins(:time_slot).where(time_slots: { specialty_id: specialty_id }).count
    completed_count     = Appointment.completed.joins(:time_slot).where(time_slots: { specialty_id: specialty_id }).count
    pending_count       = Appointment.where.not(status: :completed).joins(:time_slot).where(time_slots: { specialty_id: specialty_id }).count

    # 3. Active interns + number of specialties they cover
    intern_profile        = Profile.find_by(name: 'Estagiário')
    interns_scope         = User.where(profile_id: intern_profile.id, specialty_id: specialty_id)
    active_interns_count  = interns_scope.count
    intern_specialties_count = Specialty.joins(:users)
                                        .merge(interns_scope)
                                        .distinct
                                        .count('specialties.id')

    # 4. Completion rate (completed / total)
    completion_rate = if total_appointments.zero?
                        0.0
                      else
                        ((completed_count * 100.0) / total_appointments).round
                      end
    data = {
      appointmentsToday: {
        total:          appointments_today,
        percentChange: percent_change
      },
      totalAppointments: {
        total:      total_appointments,
        completed:  completed_count,
        pending:    pending_count
      },
      interns: {
        activeCount:        active_interns_count,
        specialtiesCount:   intern_specialties_count
      },
      completionRate: completion_rate   # e.g. 68 means 68 %
    }

    render json: { data: data }, status: :ok
  end
end
