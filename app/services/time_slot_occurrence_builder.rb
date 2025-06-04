# app/services/time_slot_occurrence_builder.rb
require "ice_cube"
require "ostruct"

class TimeSlotOccurrenceBuilder
  def initialize(time_slot, from:, to:)
    @slot = time_slot
    @from = from.to_date
    @to   = to.to_date
  end

  # ---------------------------------------------------------
  def call
    occurrences =
      if @slot.recurrence_rule.present?
        build_from_recurrence
      else
        build_single_day
      end

    # ======= exceções parciais (por horário) =======
    partials = @slot.exceptions.where.not(start_time: nil)
    occurrences.reject! do |occ|
      Appointment.exists?(
        time_slot_id: occ[:time_slot_id],
        date: occ[:start_at].to_date,
        start_time: occ[:start_at]..(occ[:end_at] - 1.second)
      )
    end

    occurrences
  end

  # ---------------------------------------------------------
  private

  # ---------- caso tenha recurrence_rule ----------
  def build_from_recurrence
    sched = IceCube::Schedule.new(dummy_start_date)
    sched.add_recurrence_rule(build_rule)

    # exceções inteiras (cancelar o dia todo)
    @slot.exceptions.where(start_time: nil).find_each do |ex|
      sched.add_exception_time(Time.zone.local(ex.date.year, ex.date.month, ex.date.day))
    end

    sched
      .occurrences_between(@from, @to)
      .map { |occ| build_hash_for(occ.to_date) }
  end

  # ---------- caso NÃO tenha recurrence_rule ----------
  def build_single_day
    return [] unless @slot.date && (@from..@to).cover?(@slot.date)

    # ignora se houver exceção completa para esse dia
    return [] if @slot.exceptions.exists?(date: @slot.date, start_time: nil)

    [build_hash_for(@slot.date)]
  end

  # ---------------------------------------------------------
  # helpers de exceção parcial
  def ex_start(ex) = Time.zone.local(ex.date.year, ex.date.month, ex.date.day,
                                     ex.start_time.hour, ex.start_time.min, ex.start_time.sec)
  def ex_end(ex)   = Time.zone.local(ex.date.year, ex.date.month, ex.date.day,
                                     ex.end_time.hour, ex.end_time.min, ex.end_time.sec)

  # ---------------------------------------------------------
  # dados para IceCube
  def dummy_start_date
    Time.zone.local(@slot.recurrence_rule.start_date.year,
                    @slot.recurrence_rule.start_date.month,
                    @slot.recurrence_rule.start_date.day)
  end

  def build_rule
    IceCube::Rule.weekly
                 .day(@slot.week_day)
                 .until(@slot.recurrence_rule.end_date)
  end

  # ---------------------------------------------------------
  # hash final entregue à API
  def build_hash_for(day)
    start_at = Time.zone.local(day.year, day.month, day.day,
                               @slot.start_time.hour, @slot.start_time.min, @slot.start_time.sec)

    end_at   = Time.zone.local(day.year, day.month, day.day,
                               @slot.end_time.hour,   @slot.end_time.min,   @slot.end_time.sec)

    {
      id:              @slot.id,
      start_at:        start_at,
      end_at:          end_at,
      time_slot_id:    @slot.id,
      is_recurring:    @slot.recurrence_rule.present?,   # ← NOVO
      campus_id:       @slot.college_location_id,
      campus_name:     @slot.college_location&.name,
      specialty_id:    @slot.specialty_id,
      specialty_name:  @slot.specialty&.name
    }
  end
end
