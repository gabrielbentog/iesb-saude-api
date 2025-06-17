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
