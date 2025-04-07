class Api::ConsultationRoomsController < ApplicationController
  before_action :set_consultation_room, only: %i[ show update destroy ]

  # GET /api/college_locations/:college_location_id/consultation_rooms
  def index
    @consultation_rooms = ConsultationRoom.all

    render json: @consultation_rooms, each_serializer: ConsultationRoomSerializer, status: :ok
  end

  # GET /api/college_locations/:college_location_id/consultation_rooms
  def show
    render json: @consultation_room, serializer: ConsultationRoomSerializer
  end

  # POST /api/college_locations/:college_location_id/consultation_rooms
  def create
    @consultation_room = ConsultationRoom.new(consultation_room_params)

    if @consultation_room.save
      render json: @consultation_room, serializer: ConsultationRoomSerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@consultation_room.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/college_locations/:college_location_id/consultation_rooms
  def update
    if @consultation_room.update(consultation_room_params)
      render json: @consultation_room, serializer: ConsultationRoomSerializer
    else
      render json: ErrorSerializer.serialize(@consultation_room.errors), status: :unprocessable_entity
    end
  end

  # DELETE /api/college_locations/:college_location_id/consultation_rooms
  def destroy
    @consultation_room.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_consultation_room
    @consultation_room = ConsultationRoom.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def consultation_room_params
    params.expect(consultation_room: [ :college_location_id, :specialty_id, :name, :active ])
  end
end
