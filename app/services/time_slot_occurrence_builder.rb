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

    schedule.occurrences_between(@from, @to).map do |occ|
      build_hash_for(occ.to_date)
    end
  end

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
