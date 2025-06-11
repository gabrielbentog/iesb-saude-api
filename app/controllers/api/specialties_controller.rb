class Api::SpecialtiesController < Api::ApiController
  before_action :set_specialty, only: %i[ show update destroy ]

  # GET /api/college_locations/:college_location_id/specialties
  def index
    specialty_id = current_api_user.specialty_id
    @specialties = Specialty.all.joins(:college_locations).where(college_locations: { id: params[:college_location_id] })
    @specialties = @specialties.where(id: specialty_id) if specialty_id.present?

    render json: @specialties, each_serializer: SpecialtySerializer, status: :ok
  end

  # GET /api/specialties/1
  def show
    render json: @specialty, serializer: SpecialtySerializer
  end

  # POST /api/specialties
  def create
    @specialty = Specialty.new(specialty_params)

    if @specialty.save
      render json: @specialty, serializer: SpecialtySerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@specialty.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/specialties/1
  def update
    if @specialty.update(specialty_params)
      render json: @specialty, serializer: SpecialtySerializer
    else
      render json: ErrorSerializer.serialize(@specialty.errors), status: :unprocessable_entity
    end
  end

  # DELETE /api/specialties/1
  def destroy
    @specialty.destroy!
  end

  # GET /api/specialties/simple
  def simple
    @specialties = Specialty.all
    render json: @specialties, each_serializer: SpecialtySimpleSerializer, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_specialty
    @specialty = Specialty.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def specialty_params
    params.expect(specialty: [ :name, :description, :active ])
  end
end
