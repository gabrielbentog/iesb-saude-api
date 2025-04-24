class Api::CalendarController < ApplicationController
  def calendar
    from = params[:start] || Date.today.beginning_of_month
    to   = params[:end]   || Date.today.end_of_month
  
    time_slots = TimeSlot
    .includes(:college_location, :specialty, :recurrence_rule)

    free = time_slots.flat_map do |slot|
      TimeSlotOccurrenceBuilder.new(slot, from:, to:).call
    end

  
    # 2. Consultas já marcadas
    busy = Appointment.where(date: from..to).map do |appt|
      {
        start_at: appt.date.to_datetime.change(hour: appt.start_time.hour,
                                                min:  appt.start_time.min),
        end_at:   appt.date.to_datetime.change(hour: appt.end_time.hour,
                                                min:  appt.end_time.min),
        patient:  appt.user.name
      }
    end
  
    render json: { free:, busy: }
  end
end