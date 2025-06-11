class Api:: CollegeLocationsController < Api::ApiController
  before_action :set_college_location, only: %i[ show update destroy ]

  # GET /api/college_locations
  def index
    specialty_id = current_api_user.specialty_id
    @college_locations = CollegeLocation.all
    @college_locations = @college_locations.joins(:specialties).where(specialties: { id: specialty_id }) if specialty_id.present?

    render json: @college_locations, each_serializer: CollegeLocationSerializer, status: :ok
  end

  # GET /api/college_locations/1
  def show
    render json: @college_location, serializer: CollegeLocationSerializer
  end

  # POST /api/college_locations
  def create
    @college_location = CollegeLocation.new(college_location_params)

    if @college_location.save
      render json: @college_location, serializer: CollegeLocationSerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@college_location.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/college_locations/1
  def update
    if @college_location.update(college_location_params)
      render json: @college_location, serializer: CollegeLocationSerializer
    else
      render json: ErrorSerializer.serialize(@college_location.errors), status: :unprocessable_entity
    end
  end

  # DELETE /api/college_locations/1
  def destroy
    @college_location.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_college_location
    @college_location = CollegeLocation.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def college_location_params
    params.expect(college_location: [ :name, :location ])
  end
end
