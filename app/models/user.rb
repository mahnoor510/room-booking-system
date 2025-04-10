class User < ApplicationRecord
  has_many :bookings
  enum role: { customer: 0, admin: 1 }

  validates :name, :email, presence: true
  validates :email, uniqueness: true
end
