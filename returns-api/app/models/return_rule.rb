class ReturnRule < ApplicationRecord
  belongs_to :merchant
  belongs_to :product, optional: true

  validates :window_days, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :merchant_id, presence: true
  validate :at_least_one_option_enabled # run method to validate options

  private

  def at_least_one_option_enabled
    unless replacement_allowed? || refund_allowed?
      errors.add(:base, "At least one of replacement_allowed or refund_allowed must be true") # error to entire object
    end
  end
end
