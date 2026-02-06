class ReturnRequest < ApplicationRecord
  include AASM

  belongs_to :order
  belongs_to :product
  belongs_to :merchant

  # Rails enum for status - must match AASM states
  enum :status, { requested: 0, approved: 1, rejected: 2, shipped: 3, received: 4, resolved: 5 }

  validates :reason, presence: true
  validates :requested_date, presence: true

  aasm column: :status, enum: true do  # sets status to requested by default
    state :requested, initial: true
    state :approved
    state :rejected
    state :shipped
    state :received
    state :resolved

    event :approve do # only allowed if current status is requested
      transitions from: :requested, to: :approved
    end

    event :reject do
      transitions from: :requested, to: :rejected
    end

    event :ship do
      transitions from: :approved, to: :shipped
    end

    event :mark_received do
      transitions from: :shipped, to: :received
    end

    event :resolve do
      transitions from: :received, to: :resolved
    end

    event :reset_request do
      transitions from: [:rejected, :resolved], to: :requested
    end
  end
end
