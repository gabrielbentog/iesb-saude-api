class User < ActiveRecord::Base
  extend Devise::Models
  include Filterable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  belongs_to :profile, counter_cache: true
  belongs_to :specialty, optional: true, counter_cache: true

  has_many :appointments, dependent: :nullify
  has_many :intern_appointments, class_name: 'Appointment', foreign_key: 'intern_id', dependent: :nullify

  validates :password, :password_confirmation, presence: true, on: :create
  validates :email, presence: true, uniqueness: true
  validate :intern_with_specialty

  def generate_reset_code!
    raw = rand(0..99_999).to_s.rjust(5, "0")          # "04271"
    update!(
      reset_password_code_digest: BCrypt::Password.create(raw),
      reset_password_code_sent_at: Time.current
    )
    raw
  end

  # true se o código bate e ainda está dentro do prazo (30 min)
  def valid_reset_code?(code)
    return false if reset_password_code_sent_at.nil? ||
                    reset_password_code_sent_at < 30.minutes.ago

    BCrypt::Password.new(reset_password_code_digest).is_password?(code)
  end

  # Depois de usar, zere os campos
  def clear_reset_code!
    update!(
      reset_password_code_digest: nil,
      reset_password_code_sent_at: nil
    )
  end

  def active?
    last_activity_at.present? && last_activity_at > 1.month.ago
  end

  private

  def intern_with_specialty
    if !specialty && intern?
      errors.add(:specialty, "Estágiario deve ter uma especialidade")
    end
  end

  def intern?
    profile&.name == "Estagiário"
  end
end
