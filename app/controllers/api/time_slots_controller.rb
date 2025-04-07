class Api::TimeSlotsController < ApplicationController
  before_action :set_time_slot, only: %i[ show update destroy ]

  # GET /time_slots
  def index
    @time_slots = TimeSlot.all

    render json: @time_slots, each_serializer: TimeSlotSerializer, status: :ok
  end

  # GET /time_slots/1
  def show
    render json: @time_slot, serializer: TimeSlotSerializer
  end

  # POST /time_slots
  def create
    @time_slot = TimeSlot.new(time_slot_params)

    if @time_slot.save
      render json: @time_slot, serializer: TimeSlotSerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@time_slot.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /time_slots/1
  def update
    if @time_slot.update(time_slot_params)
      render json: @time_slot, serializer: TimeSlotSerializer
    else
      render json: ErrorSerializer.serialize(@time_slot.errors), status: :unprocessable_entity
    end
  end

  # DELETE /time_slots/1
  def destroy
    @time_slot.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_time_slot
    @time_slot = TimeSlot.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def time_slot_params
    params.expect(time_slot: [ :college_location_id, :turn, :start_time, :end_time, :week_day ])
  end
end
