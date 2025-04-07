class Api::SpecialtiesController < ApplicationController
  before_action :set_specialty, only: %i[ show update destroy ]

  # GET /specialties
  def index
    @specialties = Specialty.all

    render json: @specialties, each_serializer: SpecialtySerializer, status: :ok
  end

  # GET /specialties/1
  def show
    render json: @specialty, serializer: SpecialtySerializer
  end

  # POST /specialties
  def create
    @specialty = Specialty.new(specialty_params)

    if @specialty.save
      render json: @specialty, serializer: SpecialtySerializer, status: :created
    else
      render json: ErrorSerializer.serialize(@specialty.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /specialties/1
  def update
    if @specialty.update(specialty_params)
      render json: @specialty, serializer: SpecialtySerializer
    else
      render json: ErrorSerializer.serialize(@specialty.errors), status: :unprocessable_entity
    end
  end

  # DELETE /specialties/1
  def destroy
    @specialty.destroy!
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
