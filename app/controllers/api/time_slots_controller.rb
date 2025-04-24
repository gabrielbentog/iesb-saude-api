class Api::TimeSlotsController < ApplicationController
  before_action :set_time_slot, only: %i[ show update destroy ]

  # GET /api/time_slots
  def index
    @time_slots = TimeSlot.all

    render json: @time_slots, each_serializer: TimeSlotSerializer, status: :ok
  end

  # GET /api/time_slots/1
  def show
    render json: @time_slot, serializer: TimeSlotSerializer
  end

  # POST /api/time_slots
  def create
    @time_slots = TimeSlot.create!(time_slots_params)

    render json: @time_slots, each_serializer: TimeSlotSerializer, status: :created

    rescue ActiveRecord::RecordInvalid => e
      render json: ErrorSerializer.serialize(e.record.errors), status: :unprocessable_entity
  end

  # PATCH/PUT /api/time_slots/1
  def update
    if @time_slot.update(time_slot_params)
      render json: @time_slot, serializer: TimeSlotSerializer
    else
      render json: ErrorSerializer.serialize(@time_slot.errors), status: :unprocessable_entity
    end
  end

  # DELETE /api/time_slots/1
  def destroy
    @time_slot.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])  # corrigido
  end

  # Only allow a list of trusted parameters through.
  def time_slots_params
    params.require(:time_slots).map do |ts|
      ts.permit(
        :college_location_id,
        :specialty_id,
        :date,
        :week_day,
        :start_time,
        :end_time,
        recurrence_rule_attributes: %i[
          id
          repeat_type
          start_date
          end_date
          frequency_type
        ]
      )
    end
  end
end
