# app/mailers/user_mailer.rb
class UserMailer < Devise::Mailer
  default template_path: "devise/mailer"
  default from: ENV['MAILER_DEFAULT_FROM'], reply_to: ENV['MAILER_DEFAULT_REPLY_TO']

  def reset_password_instructions(user, code)
    @resource    = user
    @reset_code  = code
    mail to: user.email, subject: "Código de redefinição de senha"
  end
end
