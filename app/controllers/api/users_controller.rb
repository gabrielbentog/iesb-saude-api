class Api::UsersController < Api::ApiController
  before_action :set_user, only: [:show, :update, :destroy]
  skip_before_action :authenticate_api_user!, only: [:create, :code_verify]

  # GET /api/users
  def index
    @users = User.all.includes(:profile)
    render json: @users, each_serializer: UserSerializer
  end

  # GET /api/users/:id
  def show
    render json: @user, serializer: UserSerializer
  end

  # GET /api/users/me
  def me
    if current_api_user
      render json: current_api_user, serializer: UserSerializer
    else
      render json: { message: 'Usuário não autenticado' }, status: :unauthorized
    end
  end

  # POST /api/users/:id
  def create
    @specialty_id = current_api_user.specialty_id if current_api_user

    if current_api_user.nil?
      profile = Profile.find_or_create_by(name: 'Paciente')
    elsif user_params[:profile_name].present? && current_api_user.profile.name == 'Gestor'
      profile = Profile.find_or_create_by(name: user_params[:profile_name])
      password = "#{user_params[:name].split(' ').first.titlecase}#{Date.today.year}@"
      params[:user][:password] = password
      params[:user][:password_confirmation] = password
    else
      profile = nil
    end

    clean_params = user_params.except(:profile_name).merge(specialty_id: @specialty_id)

    @user = User.new(clean_params.merge(profile: profile))
    if @user.save
      if current_api_user.nil?
        auth_token = @user.create_new_auth_token.try(:[], 'Authorization')
        render json: {token: auth_token, user: UserSerializer.new(@user)}, status: :created
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

  # GET /api/users/interns
  def interns
    specialty_id = current_api_user.specialty_id
    intern_profile = Profile.find_by(name: 'Estagiário')
    @interns = User.where(profile: intern_profile, specialty_id: specialty_id).includes(:profile)

    @interns = @interns.apply_filters(params)
    meta = generate_meta(@interns)

    render json: @interns, each_serializer: InternSerializer, meta: meta
  end

  # GET /api/users/code_verify
  def code_verify
    user = User.find_by(email: params.require(:email))
    code = params.require(:code)

    if user&.valid_reset_code?(code)
      render json: { valid: true }, status: :ok
    else
      render json: { valid: false,
                     errors: ["Código inválido ou expirado"] }, status: :unprocessable_entity
    end
  end

  # PUT /api/users/:id/change-password
  def change_password
    if current_api_user&.valid_password?(params[:current_password])
      if current_api_user.update(password: params[:new_password])
        render json: { message: 'Senha alterada com sucesso' }, status: :ok
      else
        render json: ErrorSerializer.serialize(current_api_user.errors), status: :unprocessable_entity
      end
    else
      render json: { message: 'Senha atual inválida' }, status: :unauthorized
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Usuário não encontrado' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:email, :cpf, :phone, :password, :password_confirmation, :name, :registration, :specialty_id, :profile_name)
  end
end
