class BookingLog < ApplicationRecord
  belongs_to :booking

  validates :action, presence: true
end
