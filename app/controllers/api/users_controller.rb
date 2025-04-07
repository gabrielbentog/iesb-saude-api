class Api::UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  # before_action :authenticate_request!, only: [:index, :show, :update, :destroy]

  # GET /api/users
  def index
    @users = User.all.includes(:profiles)
    render json: @users, each_serializer: UserSerializer
  end

  # GET /api/users/:id
  def show
    render json: @user, serializer: UserSerializer
  end

  # POST /api/users/:id
  def create
    profile = if current_user.nil?
      Profile.find_by(name: 'Paciente')
    end

    @user = User.new(user_params.merge(profile: profile))
    if @user.save
      if current_user.nil?
        token = AuthenticationService.encode(@user)
        render json: {token: token, user: UserSerializer.new(@user)}, status: :created
      else
        render json: @user, serializer: UserSerializer, status: :created
      end
    else
      render json: ErrorSerializer.serialize(@user.errors), status: :unprocessable_entity
    end
  end

  # PUT/PATCH /api/users/:id
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: ErrorSerializer.serialize(@user.errors), status: :unprocessable_entity
    end
  end

  # DELETE /api/users/:id
  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Usuário não encontrado' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end
