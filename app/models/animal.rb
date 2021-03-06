class Animal < ApplicationRecord
  belongs_to :user
  has_many :bookings
  mount_uploader :photo, PhotoUploader
  validates :title, :description, :address, :daily_price, :photo, presence: true
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  def rating
    @bookings = bookings.reject { |b| b.review.nil? }
    @ratings = @bookings.map do |booking|
      booking.review.rating
    end
    if @ratings == []
      return 0
    else
      rating = @ratings.reduce(&:+).fdiv(@ratings.size)
      full = rating.floor
      half = (rating - rating.floor) >= 0.5 ? 1 : 0
      empty = (5 - rating).floor
      return [full, half, empty]
    end
  end

  def self.search(search)
    where("title ILIKE ? OR description ILIKE ?", "%#{search}%", "%#{search}%")
  end

end

