class Api::CalendarController < Api::ApiController
  def calendar
    from = params[:start] || Date.today.beginning_of_month
    to   = params[:end]   || Date.today.end_of_month
    specialty_id = params[:specialty_id]
    college_location_id = params[:campus_id]

    time_slots = TimeSlot
    .includes(:college_location, :specialty, :recurrence_rule)

    time_slots = time_slots.where(specialty_id:) if specialty_id.present?
    time_slots = time_slots.where(college_location_id:) if college_location_id.present?

    free = time_slots.flat_map do |slot|
      TimeSlotOccurrenceBuilder.new(slot, from:, to:).call
    end
  
    # 2. Consultas já marcadas
    busy = Appointment.where(date: from..to).map do |appt|
      time_slot = appt.time_slot
      {
        startAt: appt.date.in_time_zone.change(hour: appt.start_time.hour,
                      min:  appt.start_time.min),
        endAt:   appt.date.in_time_zone.change(hour: appt.end_time.hour,
                      min:  appt.end_time.min),
        date:     appt.date,
        patient:  appt.user.name,
        timeSlotId:    time_slot.id,
        isRecurring:    time_slot.recurrence_rule.present?,   # ← NOVO
        campusId:       time_slot.college_location_id,
        campusName:     time_slot.college_location&.name,
        specialtyId:    time_slot.specialty_id,
        specialtyName:  time_slot.specialty&.name
      }
    end

    render json: { free:, busy: }
  end
end