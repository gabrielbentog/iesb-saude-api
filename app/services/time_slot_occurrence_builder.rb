# app/services/time_slot_occurrence_builder.rb
require "ice_cube"
require "ostruct"

class TimeSlotOccurrenceBuilder
  def initialize(time_slot, from:, to:)
    @slot = time_slot
    @from = from.to_date
    @to   = to.to_date
  end

  def call
    schedule = IceCube::Schedule.new(dummy_start_date)
    schedule.add_recurrence_rule(build_rule)
  
    # ------ exceções completas ------
    @slot.exceptions.where(start_time: nil).find_each do |ex|
      schedule.add_exception_time(Time.zone.local(ex.date.year, ex.date.month, ex.date.day))
    end
  
    occurrences = schedule.occurrences_between(@from, @to).map { |occ| build_hash_for(occ.to_date) }
  
    # ------ exceções parciais (hora a hora) ------
    partials = @slot.exceptions.where.not(start_time: nil)
    occurrences.reject! do |occ|
      partials.any? do |ex|
        ex.date == occ[:start_at].to_date &&
          occ[:start_at].between?(ex_start(ex), ex_end(ex) - 1.second)
      end
    end
  
    occurrences
  end

  def ex_start(ex) = Time.zone.local(ex.date.year, ex.date.month, ex.date.day,
    ex.start_time.hour, ex.start_time.min, ex.start_time.sec)
  def ex_end(ex)   = Time.zone.local(ex.date.year, ex.date.month, ex.date.day,
    ex.end_time.hour,   ex.end_time.min,   ex.end_time.sec)

  private

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

  # -----  Aqui juntamos dados de negócio e metadados -----
  def build_hash_for(day)
    start_at = Time.zone.local(
      day.year, day.month, day.day,
      @slot.start_time.hour, @slot.start_time.min, @slot.start_time.sec
    )

    end_at   = Time.zone.local(
      day.year, day.month, day.day,
      @slot.end_time.hour, @slot.end_time.min, @slot.end_time.sec
    )

    {
      start_at:, end_at:,
      time_slot_id:          @slot.id,
      campus_id:             @slot.college_location_id,
      campus_name:           @slot.college_location&.name,
      specialty_id:          @slot.specialty_id,
      specialty_name:        @slot.specialty&.name
    }
  end
end
