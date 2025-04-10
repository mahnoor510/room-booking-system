class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :booking_logs, dependent: :destroy

  enum status: { is_pending: 0, confirmed: 1, cancelled: 2 }

  validates :start_time, :end_time, :status, presence: true
  validate :rooms_limit, on: :create
  validate :no_overlap, on: :create
  validate :room_is_active, on: :create
  validate :end_time_after_start_time

  before_save :calculate_total_price, if: :start_time_or_end_time_changed?
  after_create :log_booking_creation
  after_update :log_booking_cancellation, if: :saved_change_to_status?

  def cancel_booking
    self.status = :cancelled
    self.total_price *= 0.95 if start_time >= 24.hours.ago
    save
  end

  private

  def rooms_limit
    active_bookings_count = user.bookings.where.not(status: :cancelled).where('end_time > ?', Time.now).count
    if active_bookings_count >= 3
      errors.add(:base, "You can only book up to 3 rooms at a time")
    end
  end

  def no_overlap
    overlapping_bookings = Booking.where(room_id: room_id)
                                  .where("start_time < ? AND end_time > ?", end_time, start_time)
    if overlapping_bookings.exists?
      errors.add(:base, "This room is already booked during this time period")
    end
  end

  def room_is_active
    unless room.active?
      errors.add("#{room.name} is not available for booking")
    end
  end

  def end_time_after_start_time
    if start_time <= Time.now
      errors.add(:start_time, "must be in the future")
    end
  
    if end_time <= Time.now
      errors.add(:end_time, "must be in the future")
    end
  
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def start_time_or_end_time_changed?
    start_time_changed? || end_time_changed?
  end

  def calculate_total_price
    total_hours = (end_time - start_time) / 1.hour
    self.total_price = total_hours * room.price_per_hour

    if total_hours > 4
      self.total_price *= 0.90
      puts "discount applied"
    end
  end

  def log_booking_creation
    BookingLog.create!(booking_id: id, action: 'new booking created')
  end

  def log_booking_cancellation
    if cancelled?
      BookingLog.create!(booking_id: id, action: 'booking cancelled')
    end
  end
end