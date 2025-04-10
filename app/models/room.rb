class Room < ApplicationRecord
  has_many :bookings

  validates :name, presence: true, uniqueness: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_hour, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
end
