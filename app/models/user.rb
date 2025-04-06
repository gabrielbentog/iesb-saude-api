class User < ActiveRecord::Base
  extend Devise::Models

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  belongs_to :profile, counter_cache: true

  validates :password, :password_confirmation, presence: true, on: :create
  validates :email, presence: true, uniqueness: true
end
