class Api::TimeSlotExceptionsController < Api::ApiController
  before_action :set_time_slot_exception, only: %i[ show update destroy ]

  # GET /time_slot_exceptions
  def index
    @time_slot_exceptions = TimeSlotException.all

    render json: @time_slot_exceptions, each_serializer: TimeSlotExceptionSerializer, status: :ok
  end

  # GET /time_slot_exceptions/1
  def show
    render json: @time_slot_exception, serializer: TimeSlotExceptionSerializer
  end

  # POST /time_slot_exceptions
  def create
    @time_slot_exception = TimeSlotException.new(time_slot_exception_params)

    if @time_slot_exception.save
      render json: @time_slot_exception, serializer: TimeSlotExceptionSerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@time_slot_exception.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /time_slot_exceptions/1
  def update
    if @time_slot_exception.update(time_slot_exception_params)
      render json: @time_slot_exception, serializer: TimeSlotExceptionSerializer
    else
      render json: ErrorSerializer.serialize(@time_slot_exception.errors), status: :unprocessable_entity
    end
  end

  # DELETE /time_slot_exceptions/1
  def destroy
    @time_slot_exception.destroy!
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_time_slot_exception
    @time_slot_exception = TimeSlotException.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def time_slot_exception_params
    params.require(:time_slot_exception).permit(:time_slot_id, :date, :start_time, :end_time, :reason)
  end
end
