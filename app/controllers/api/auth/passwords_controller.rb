# app/controllers/api/auth/passwords_controller.rb
class Api::Auth::PasswordsController < DeviseTokenAuth::PasswordsController
  skip_before_action :authenticate_api_user!, only: [:create, :update], raise: false

  ####################################################################
  # POST /api/auth/password
  ####################################################################
  def create
    user = User.find_by(email: params.require(:email))

    if user
      code = user.generate_reset_code!          # 5 dígitos
      UserMailer.reset_password_instructions(user, code).deliver_later
    end

    render json: { message: "Se o e-mail existir, enviamos um código." }, status: :ok
  end

  ####################################################################
  # PUT /api/auth/password
  # params: { email, code, password, password_confirmation }
  ####################################################################
  def update
    user = User.find_by(email: params.require(:email))

    if !user&.valid_reset_code?(params[:code])
      return render_error(:unauthorized,
                          { code: ["Código inválido ou expirado"] })
    end

    if user.reset_password(params[:password], params[:password_confirmation])
      user.clear_reset_code!
      render json: { message: "Senha redefinida com sucesso" }, status: :ok
    else
      render_error(:unprocessable_entity, user.errors.messages)
    end
  end

  # mantém o helper do gem para erros personalizados
  def render_error(status, errors, data = nil)
    super
  end
end
