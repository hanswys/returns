# frozen_string_literal: true

# Tracks every state transition for return requests
# Provides audit trail for compliance and debugging
#
class StatusAuditLog < ApplicationRecord
  belongs_to :return_request

  validates :to_status, presence: true
  validates :event, presence: true
  validates :triggered_by, presence: true

  # Store metadata as JSON
  serialize :metadata, coder: JSON

  scope :recent, -> { order(created_at: :desc) }
  scope :for_event, ->(event) { where(event: event) }
end
