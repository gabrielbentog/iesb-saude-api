class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :appointment, optional: true

  validates :title, presence: true
  validates :body, presence: true

  scope :unread, -> { where(read: false) }
end
