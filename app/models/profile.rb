class Profile < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, presence: true
end
