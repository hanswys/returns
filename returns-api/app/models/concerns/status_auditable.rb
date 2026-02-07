# frozen_string_literal: true

# Concern for automatic status change auditing
# Extracts audit logging from ReturnRequest following SRP
#
# Usage:
#   class ReturnRequest < ApplicationRecord
#     include AASM
#     include StatusAuditable
#   end
#
# Note: Must be included AFTER aasm is set up, as it hooks into AASM callbacks
#
module StatusAuditable
  extend ActiveSupport::Concern

  included do
    has_many :status_audit_logs, dependent: :destroy

    # Hook into AASM's fire! method to log transitions
    after_commit :check_and_log_status_change, on: [:create, :update]
  end

  private

  # Called after save - checks if status changed and logs it
  def check_and_log_status_change
    return unless saved_change_to_status?

    from_status = status_before_last_save
    to_status = status

    status_audit_logs.create!(
      from_status: from_status,
      to_status: to_status,
      event: determine_event(from_status, to_status),
      triggered_by: Current.actor || 'system',
      metadata: build_audit_metadata
    )
  end

  def determine_event(from_status, to_status)
    # Map status transitions to event names
    case [from_status, to_status]
    when ['requested', 'approved'] then 'approve'
    when ['requested', 'rejected'] then 'reject'
    when ['approved', 'shipped'] then 'ship'
    when ['shipped', 'received'] then 'mark_received'
    when ['received', 'resolved'] then 'resolve'
    else 'transition'
    end
  end

  def build_audit_metadata
    {
      transitioned_at: Time.current.iso8601,
      request_id: id
    }
  end
end

